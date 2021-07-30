import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    var message = event.message.toString();
    return [color!('$emoji $message')];
  }
}

var slog = Logger(printer: SimpleLogPrinter());
var nlog = Logger(printer: PrettyPrinter());
var nslog = Logger(printer: PrettyPrinter(methodCount: 0));
