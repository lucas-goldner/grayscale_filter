import 'dart:io';

import 'package:args/args.dart';
import 'package:image/image.dart';

const inputOptionName = 'input';
const outputOptionName = 'output';
const amountOptionName = 'amount';
const maskOptionName = 'mask';
const maskChannelOptionName = 'maskChannel';

Channel fromStringToChannel(String channel) {
  switch (channel) {
    case 'red':
      return Channel.red;
    case 'green':
      return Channel.green;
    case 'blue':
      return Channel.blue;
    case 'alpha':
      return Channel.alpha;
    case 'luminance':
      return Channel.luminance;
    default:
      throw ArgumentError('Invalid channel: $channel');
  }
}

int main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(inputOptionName, mandatory: true, abbr: 'i')
    ..addOption(outputOptionName, mandatory: true, abbr: 'o')
    ..addOption(amountOptionName, mandatory: false, abbr: 'a')
    ..addOption(maskOptionName, mandatory: false, abbr: 'm')
    ..addOption(maskChannelOptionName, mandatory: false, abbr: 'c');

  ArgResults argResults = parser.parse(arguments);
  final String inputFilePath = argResults[inputOptionName];
  final String outputFilePath = argResults[outputOptionName];
  final num amount = argResults[amountOptionName] != null
      ? num.parse(argResults[amountOptionName])
      : 1;
  final Channel maskChannel = argResults[maskChannelOptionName] != null
      ? fromStringToChannel(argResults[maskChannelOptionName])
      : Channel.luminance;
  final String? maskPath = argResults[maskOptionName];

  try {
    final Image image = decodeImage(File(inputFilePath).readAsBytesSync())!;
    final Image grayScaledImage;
    if (maskPath != null) {
      final Image mask = decodeImage(File(maskPath).readAsBytesSync())!;
      grayScaledImage = grayscale(image,
          amount: amount, mask: mask, maskChannel: maskChannel);
    } else {
      grayScaledImage =
          grayscale(image, amount: amount, maskChannel: maskChannel);
    }
    File(outputFilePath).writeAsBytesSync(encodeJpg(grayScaledImage));

    return 0;
  } catch (e) {
    stderr.writeln('Unexpected exception when producing the image.\n'
        'Details: $e');
    return 1;
  }
}
