import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_export.dart';

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (this.startsWith('http') || this.startsWith('https')) {
      if (this.endsWith('.svg')) {
        return ImageType.networkSvg;
      }
      return ImageType.network;
    } else if (this.endsWith('.svg')) {
      return ImageType.svg;
    } else if (this.startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, networkSvg, file, unknown }

class CustomImageView extends StatelessWidget {
  CustomImageView(
      {this.imagePath,
      this.height,
      this.width,
      this.color,
      this.fit,
      this.alignment,
      this.onTap,
      this.radius,
      this.margin,
      this.border,
      this.placeHolder,
      this.text,
      this.textStyle,
      this.spacing = 4.0}) {
    if (imagePath == null || imagePath!.isEmpty) {
      imagePath = ImageConstant.imgImageNotFound;
    }
  }

  ///[imagePath] is required parameter for showing image
  late String? imagePath;

  final double? height;

  final double? width;

  final Color? color;

  final BoxFit? fit;

  final String? placeHolder;

  final Alignment? alignment;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry? margin;

  final BorderRadius? radius;

  final BoxBorder? border;

  ///[text] optional text to display with the image
  final String? text;

  ///[textStyle] style for the text
  final TextStyle? textStyle;

  ///[spacing] spacing between text and image when both are present
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: _buildCircleImage(),
        ),
      ),
    );
  }

  ///build the image with border radius
  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  ///build the image with border and border radius style
  _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    final imageWidget = _buildImageWidget();
    
    // 如果有文字，则创建文字+图片的组合
    if (text != null && text!.isNotEmpty) {
      return Container(
        height: height,
        width: width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text!,
                style: textStyle ?? TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                maxLines: 1,
              ),
            ),
            if (imageWidget != null) ...[
              SizedBox(width: spacing),
              Flexible(
                child: imageWidget,
              ),
            ],
          ],
        ),
      );
    }
    
    // 没有文字，直接返回图片
    return imageWidget ?? SizedBox.shrink();
  }

  Widget? _buildImageWidget() {
    if (imagePath == null || imagePath!.isEmpty) {
      return null;
    }
    
    switch (imagePath!.imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: this.color != null
              ? ColorFilter.mode(
                  this.color ?? appTheme.transparentCustom, BlendMode.srcIn)
              : null,
        );
      case ImageType.file:
        return Image.file(
          File(imagePath!),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
      case ImageType.networkSvg:
        return SvgPicture.network(
          imagePath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: this.color != null
              ? ColorFilter.mode(
                  this.color ?? appTheme.transparentCustom, BlendMode.srcIn)
              : null,
        );
      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: imagePath!,
          color: color,
          placeholder: (context, url) => Container(
            height: 30,
            width: 30,
            child: LinearProgressIndicator(
              color: appTheme.grey200,
              backgroundColor: appTheme.grey100,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeHolder ?? ImageConstant.imgImageNotFound,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          ),
        );
      case ImageType.png:
      default:
        return Image.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }
}
