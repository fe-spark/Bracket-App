import 'package:flutter_html/flutter_html.dart';
import '/widgets/expandable.dart';
import '/model/film_play_info/data.dart';
import '/model/film_play_info/detail.dart';
import '/model/film_play_info/list.dart';
import '/plugins.dart';

class Series extends StatefulWidget {
  final Data? data;

  const Series({
    super.key,
    required this.data,
  });

  @override
  State<Series> createState() => _SeriesState();
}

class _SeriesState extends State<Series> {
  _SeriesState();
  final smoothExpandableKey = GlobalKey<SmoothExpandableState>();
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var info = context.watch<PlayVideoIdsStore>();
    Detail? detail = widget.data?.detail;
    List<ListData?>? list = detail?.list;
    int? originIndex = info.originIndex;
    int? teleplayIndex = info.teleplayIndex;
    var linkList = list?[originIndex]?.linkList ?? [];

    return LoadingViewBuilder(
      loading: list == null,
      builder: (_) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            detail?.name ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            (detail?.descriptor?.subTitle == "" ||
                                    detail?.descriptor?.subTitle == null)
                                ? '暂无数据'
                                : (detail?.descriptor?.subTitle ?? '暂无数据'),
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _isOpen
                        ? const Icon(Icons.expand_less)
                        : const Icon(Icons.expand_more),
                    onPressed: () {
                      smoothExpandableKey.currentState?.toggle();
                    },
                  )
                ],
              ),
              SmoothExpandable(
                key: smoothExpandableKey,
                onExpandChanged: (value) {
                  setState(() {
                    _isOpen = value;
                  });
                },
                child: Card(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Html(
                    data: detail?.descriptor?.content ?? '暂无介绍',
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(
                height: 12,
              ),
              if (list != null)
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    children: list.mapIndexed((i, e) {
                      return ChoiceChip(
                          label: Text(e?.name ?? '未知源'),
                          selected: originIndex == i,
                          onSelected: (_) {
                            context
                                .read<PlayVideoIdsStore>()
                                .setVideoInfo(i, teleplayIndex: 0, startAt: 0);
                          });
                    }).toList(),
                  ),
                ),
              const SizedBox(
                height: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: list?[originIndex] != null && linkList.isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                final containerWidth = constraints.maxWidth;
                                const spacing = 10.0;
                                // 计算单个item的基础宽度（4列）
                                final baseWidth =
                                    (containerWidth - spacing * 3) / 4;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: linkList.mapIndexed((i, e) {
                                    final colorScheme =
                                        Theme.of(context).colorScheme;
                                    final isSelected = i == teleplayIndex;
                                    final text = '${e.episode}';

                                    // 根据文本长度决定宽度
                                    double itemWidth;
                                    bool needsScroll = false;

                                    if (text.length <= 4) {
                                      // 短文本：1/4宽度
                                      itemWidth = baseWidth;
                                    } else if (text.length <= 8) {
                                      // 中等文本：1/2宽度
                                      itemWidth = baseWidth * 2 + spacing;
                                    } else {
                                      // 长文本：全宽
                                      itemWidth = containerWidth;
                                      // 超过12字符可能需要滚动
                                      if (text.length > 12) {
                                        needsScroll = true;
                                      }
                                    }

                                    return SizedBox(
                                      width: itemWidth,
                                      child: InkWell(
                                        onTap: () {
                                          info.setVideoInfo(
                                            info.originIndex,
                                            teleplayIndex: i,
                                            startAt: 0,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? colorScheme.primaryContainer
                                                : colorScheme
                                                    .surfaceContainerHigh,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: isSelected
                                                ? Border.all(
                                                    color: colorScheme.primary,
                                                    width: 2)
                                                : null,
                                          ),
                                          child: needsScroll
                                              ? SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    text,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isSelected
                                                          ? colorScheme
                                                              .onPrimaryContainer
                                                          : colorScheme
                                                              .onSurface,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  text,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isSelected
                                                        ? colorScheme
                                                            .onPrimaryContainer
                                                        : colorScheme.onSurface,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            )
                          : const Center(
                              child: Text('暂无数据'),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
