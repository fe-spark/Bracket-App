///检测时间距离当前是今天 昨天 前天还是某个日期 跨年显示 年-月-日 不跨年显示 月-日
class DateScope {
  static String formatDuration(int seconds) {
    int hours = seconds ~/ 3600; // 每小时3600秒
    int minutes = (seconds % 3600) ~/ 60; // 计算剩余秒数中的分钟部分
    int secs = seconds % 60; // 计算剩余秒数中的秒部分

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  static DateTime timestampToDate(int timestamp) {
    DateTime dateTime = DateTime.now();

    ///如果是十三位时间戳返回这个
    if (timestamp.toString().length == 13) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp.toString().length == 16) {
      ///如果是十六位时间戳
      dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    }
    return dateTime;
  }

  static DateTime _changeTimeDate(time) {
    ///如果传进来的是字符串 13/16位 而且不包含-
    DateTime dateTime = DateTime.now();
    if (time is String) {
      if ((time.length == 13 || time.length == 16) && !time.contains("-")) {
        dateTime = timestampToDate(int.parse(time));
      } else {
        dateTime = DateTime.parse(time);
      }
    } else if (time is int) {
      dateTime = timestampToDate(time);
    }
    return dateTime;
  }

  static String getDateScope({required checkDate}) {
    String temp = DateTime.now().toString();
    List listTemp = temp.split(" ");
    temp = listTemp[0];
    DateTime nowTime = DateTime.parse(temp);
    DateTime checkTime = _changeTimeDate(checkDate);

    Duration diff = checkTime.difference(nowTime);

    ///如果不同年 返回 年-月-日 小时:分钟 不显示秒及其.000
    if (checkTime.year != nowTime.year) {
      return checkTime.toString().substring(0, checkTime.toString().length - 7);
    }

    /// 同年判断是不是前天/昨天/今天/
    if ((diff < const Duration(hours: 24)) &&
        (diff > const Duration(hours: 0))) {
      return "今天 ${_dataNum(checkTime.hour)}:${_dataNum(checkTime.minute)}";
    } else if ((diff < const Duration(hours: 0)) &&
        (diff > const Duration(hours: -24))) {
      return "昨天 ${_dataNum(checkTime.hour)}:${_dataNum(checkTime.minute)}";
    } else if (diff < const Duration(hours: -24) &&
        diff > const Duration(hours: -48)) {
      return "前天 ${_dataNum(checkTime.hour)}:${_dataNum(checkTime.minute)}";
    }

    ///如果剩下都不是就返回 月-日 然后时间
    return checkTime.toString().substring(5, checkTime.toString().length - 7);
  }

  static String _dataNum(numb) {
    if (numb < 10) {
      return "0$numb";
    }
    return numb.toString();
  }
}
