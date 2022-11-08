import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:zhi_hu_news_flutter/detail_page.dart';
import 'package:zhi_hu_news_flutter/dio_service.dart';
import 'model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ctl = ScrollController();

  List<Daily> days = []; // 所有已加载的日期
  DateTime nextDate =
      DateTime.now().subtract(Duration(days: 1)); // 将要加载的日期，初始值为昨天，每次上拉加载时往前数一天
  bool loading = false; // 是否正在加载

  @override
  void initState() {
    super.initState();

    /// 添加监听器，如果上拉到listView底部，则获取前一天的数据，并更新[nextDate]
    ctl.addListener(() async {
      if (ctl.position.pixels > ctl.position.maxScrollExtent - 40) {
        /// 如果已经在加载了就取消，防止重复加载
        if (loading) return;
        loading = true;

        var daily = await DioService.getBeforeNews(nextDate);
        setState(() {
          days.add(daily);
        });
        nextDate = nextDate.subtract(Duration(days: 1));

        loading = false;
      }
    });

    /// 页面构建完毕后开始加载数据
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      onRefresh();
    });
  }

  Future<void> onRefresh() async {
    /// 获取今天的新闻，并刷新页面
    var daily = await DioService.getTodayNews();
    setState(() {
      days = [daily];
      nextDate = DateTime.now().subtract(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 左上角标题
    var date = DateTime.now(); // 获取当前时间
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

    /// 轮播图，如果[days]不为空，则至少有今天的数据，则一定有[top_stories]数据
    Widget banner = Container();
    if (days.isNotEmpty) {
      banner = SizedBox(
        height: 350,
        child: Swiper(
          itemCount: days.first.topStories.length,
          // 轮播图右下方的点点
          pagination: SwiperPagination(
            alignment: Alignment.bottomRight,
            builder: DotSwiperPaginationBuilder(
              size: 5,
              color: Colors.grey[400],
              activeColor: Colors.white,
            ),
          ),
          autoplay: true,
          itemBuilder: (context, int index) {
            var current = days.first.topStories[index]; // 当前新闻
            return Stack(
              children: [
                /// Stack最底层是图片
                Image.network(
                  current.image,
                  height: 350,
                  width: double.infinity, // 让宽度尽可能大，占满屏幕
                  fit: BoxFit.cover,
                ),

                /// Stack中间层是颜色渐变
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(int.parse(current.imageHue) | 0xff000000),
                          // [imageHue]的格式为"0xac7db3"，这里要设置alpha为ff（即完全不透明）
                        ],
                      ),
                    ),
                  ),
                ),

                /// Stack顶层是title和hint
                Container(
                  margin: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Text(
                        current.title,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis, // 文字过长时用...代替
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        current.hint,
                        style: TextStyle(color: Colors.grey[300], fontSize: 15),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      );
    }

    /// 所有的新闻
    var newsList = [banner]; // 先加上轮播图
    // 依次处理每天的新闻
    days.forEach((daily) {
      var date = DateTime.parse(daily.date);
      // 先加上日期分隔符
      newsList.add(SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20),
            Text(
              '${date.month}月${date.day}日',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 20),
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
          ],
        ),
      ));
      newsList.addAll(daily.stories.map((story) {
        return GestureDetector(
          onTap: () {
            // 点击新闻时跳转至新闻详情页
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailPage(story.url)));
          },
          child: Container(
            margin: EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis, // 文字过长时用...代替
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        story.hint,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Image.network(story.image, width: 70, height: 70),
              ],
            ),
          ),
        );
      }));
    });
    if (days.isNotEmpty) newsList.removeAt(1); // 今天的新闻不需要分隔符

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
      body: RefreshIndicator(
        onRefresh: onRefresh, // 这里设置下拉加载
        child: ListView(
          controller: ctl,
          children: newsList,
        ),
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
