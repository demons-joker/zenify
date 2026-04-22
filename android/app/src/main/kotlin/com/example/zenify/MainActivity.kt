package com.example.zenify

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), RecognitionListener {
    private val speechChannelName = "zenify/speech_recognition"
    private val attributionTag = "speechRecognition"
    private val mainHandler = Handler(Looper.getMainLooper())
    private var speechChannel: MethodChannel? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private var lastOnDevice = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        speechChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, speechChannelName)
        speechChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> result.success(initializeSpeechRecognizer(onDevice = false))
                "startListening" -> startListening(call, result)
                "stopListening" -> {
                    speechRecognizer?.stopListening()
                    notifyStatus("notListening")
                    result.success(true)
                }
                "cancelListening" -> {
                    speechRecognizer?.cancel()
                    notifyStatus("notListening")
                    result.success(true)
                }
                "dispose" -> {
                    destroyRecognizer()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        destroyRecognizer()
        super.onDestroy()
    }

    private fun startListening(call: MethodCall, result: MethodChannel.Result) {
        if (!hasAudioPermission()) {
            result.success(false)
            notifyError("error_permission_app_microphone")
            return
        }

        val onDevice = call.argument<Boolean>("onDevice") ?: false
        if (!initializeSpeechRecognizer(onDevice)) {
            result.success(false)
            notifyError("recognizer_not_available")
            return
        }

        val localeId = call.argument<String>("localeId") ?: "zh_CN"
        val partialResults = call.argument<Boolean>("partialResults") ?: true
        val listenForMillis = call.argument<Int>("listenForMillis") ?: 30000
        val pauseForMillis = call.argument<Int>("pauseForMillis") ?: 3000
        val languageTag = localeId.replace('_', '-')

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, languageTag)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, languageTag)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, partialResults)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, pauseForMillis)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, pauseForMillis)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, listenForMillis)
            if (onDevice) {
                putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            }
        }

        mainHandler.post {
            try {
                speechRecognizer?.startListening(intent)
                result.success(true)
            } catch (error: Exception) {
                result.success(false)
                notifyError("start_listening_failed: ${error.message}")
            }
        }
    }

    private fun initializeSpeechRecognizer(onDevice: Boolean): Boolean {
        if (!hasAudioPermission()) return false
        if (speechRecognizer != null && lastOnDevice == onDevice) return true
        if (onDevice && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!SpeechRecognizer.isOnDeviceRecognitionAvailable(speechContext())) {
                return false
            }
        } else if (!SpeechRecognizer.isRecognitionAvailable(speechContext())) {
            return false
        }

        destroyRecognizer()
        lastOnDevice = onDevice
        val context = speechContext()
        speechRecognizer = if (onDevice && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        } else {
            SpeechRecognizer.createSpeechRecognizer(context)
        }.apply {
            setRecognitionListener(this@MainActivity)
        }
        return true
    }

    private fun speechContext(): Context {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            createAttributionContext(attributionTag)
        } else {
            this
        }
    }

    private fun hasAudioPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun destroyRecognizer() {
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    private fun notifyStatus(status: String) {
        speechChannel?.invokeMethod("onStatus", status)
    }

    private fun notifyError(error: String) {
        speechChannel?.invokeMethod("onError", error)
    }

    private fun notifyResult(words: String) {
        speechChannel?.invokeMethod("onResult", words)
    }

    override fun onReadyForSpeech(params: Bundle?) {
        notifyStatus("listening")
    }

    override fun onBeginningOfSpeech() {
        notifyStatus("listening")
    }

    override fun onRmsChanged(rmsdB: Float) {
        speechChannel?.invokeMethod("onSoundLevel", rmsdB.toDouble())
    }

    override fun onBufferReceived(buffer: ByteArray?) = Unit

    override fun onEndOfSpeech() {
        notifyStatus("notListening")
    }

    override fun onError(error: Int) {
        notifyStatus("notListening")
        notifyStatus("done")
        notifyError(mapSpeechError(error))
    }

    override fun onResults(results: Bundle?) {
        val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        notifyResult(matches?.firstOrNull().orEmpty())
        notifyStatus("notListening")
        notifyStatus("done")
    }

    override fun onPartialResults(partialResults: Bundle?) {
        val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        val words = matches?.firstOrNull()
        if (!words.isNullOrBlank()) {
            notifyResult(words)
        }
    }

    override fun onEvent(eventType: Int, params: Bundle?) = Unit

    private fun mapSpeechError(error: Int): String {
        return when (error) {
            SpeechRecognizer.ERROR_AUDIO -> "error_audio_error"
            SpeechRecognizer.ERROR_CLIENT -> "error_client"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "error_permission"
            SpeechRecognizer.ERROR_NETWORK -> "error_network"
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "error_network_timeout"
            SpeechRecognizer.ERROR_NO_MATCH -> "error_no_match"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "error_busy"
            SpeechRecognizer.ERROR_SERVER -> "error_server"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "error_speech_timeout"
            SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED -> "error_language_not_supported"
            SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE -> "error_language_unavailable"
            SpeechRecognizer.ERROR_SERVER_DISCONNECTED -> "error_server_disconnected"
            SpeechRecognizer.ERROR_TOO_MANY_REQUESTS -> "error_too_many_requests"
            else -> "error_unknown_$error"
        }
    }
}
