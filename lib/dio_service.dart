import 'model.dart';
import 'package:dio/dio.dart';

class DioService {
  /// 获取今天的新闻
  static Future<Daily> getTodayNews() async {
    var response = await Dio()
        .get('https://news-at.zhihu.com/api/3/news/latest'); // 发送网络请求
    var daily = Daily.fromJson(response.data);
    return daily;
  }

  /// 根据日期，获取那一天的新闻
  static Future<Daily> getBeforeNews(DateTime date) async {
    date = date.add(Duration(days: 1));
    var year = date.year;
    var month = date.month;
    var day = date.day;
    var str =
        '$year${month < 10 ? '0$month' : month}${day < 10 ? '0$day' : day}'; // 获得`20221106`格式的字符串
    var response = await Dio()
        .get('https://news-at.zhihu.com/api/3/news/before/$str'); // 发送网络请求
    var daily = Daily.fromJson(response.data);
    return daily;
  }
}
