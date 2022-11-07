import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var date = DateTime.now(); // 获取当前时间

    /// 左上角标题
    var title = Row(
      children: [
        Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              monthText[date.month],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ],
        ),
        SizedBox(width: 15),
        Container(
          width: 1, // 设置一个宽度等于一的Container当作分隔线
          height: 40,
          color: Colors.grey[200],
        ),
        SizedBox(width: 15),
        Text(
          getGreetText(date.hour),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
      ],
    );

    /// 右上角的用户头像，用[ClipRRect]把矩形图片剪成圆形
    var userImage = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.network(
        'https://picx1.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_xl.jpg',
        width: 40,
        height: 40,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: title,
        // actions指的是appbar最右侧的图标
        actions: [
          Center(child: userImage),
          SizedBox(width: 15),
        ],
        elevation: 0, // 去掉阴影
        backgroundColor: Colors.white,
      ),
    );
  }

  /// 根据当前时间，获取打招呼文字
  static String getGreetText(int hour) {
    if (hour > 6 && hour < 11)
      return '早上好！';
    else if (hour >= 11 && hour < 13)
      return '中午好！';
    else if (hour >= 13 && hour < 18)
      return '下午好！';
    else
      return '晚上好！';
  }

  static const monthText = [
    '',
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月'
  ];
}
