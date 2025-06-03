import '/plugins.dart';

class UserCenterTab extends StatefulWidget {
  const UserCenterTab({super.key});

  @override
  State<StatefulWidget> createState() => _UserCenterTabState();
}

class _UserCenterTabState extends State<UserCenterTab>
    with AutomaticKeepAliveClientMixin {
  late AppLifecycleListener _listener;

  void onChangeEvent() {
    // eventBus.fire(SwitchTab(0));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      // onHide: () => _handleTransition('hide'),
      // onInactive: () => _handleTransition('inactive'),
      // onPause: () => _handleTransition('pause'),
      // onDetach: () => _handleTransition('detach'),
      // onRestart: () => _handleTransition('restart'),
      // This fires for each state change. Callbacks above fire only for
      // specific state transitions.
      onStateChange: (_) {
        print(_);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Global global = context.watch<Global>();
    final VideoSourceStore videoSourceStore = context.read<VideoSourceStore>();
    // final String? token = profileStore.data?.userToken;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        width: 4,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(30),
                      // color: Theme.of(context).primaryColor,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 50, 30),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: const NoDataView(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '当前视频源',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[200],
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      FittedBox(
                                        child: Text(
                                          getDomainName(
                                              videoSourceStore.data?.actived ??
                                                  ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.grey[100],
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),

                                      // ElevatedButton.icon(
                                      //   style: ButtonStyle(
                                      //     backgroundColor:
                                      //         MaterialStatePropertyAll(
                                      //       Colors.black87.withOpacity(.1),
                                      //     ),
                                      //   ),
                                      //   onPressed: () {},
                                      //   icon: const Icon(
                                      //     Icons.edit_outlined,
                                      //     color: Colors.blueAccent,
                                      //   ),
                                      //   label: const Text('修改'),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('观看历史'),
                            leading: const Icon(Icons.clear_all),
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MYRouter.historyPagePath);
                            },
                          ),
                          const Divider(
                            indent: 12,
                            endIndent: 12,
                          ),
                          ListTile(
                            title: const Text('系统主题'),
                            leading: const Icon(Icons.border_color),
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, MYRouter.themePagePath);
                            },
                          ),
                          const Divider(
                            indent: 12,
                            endIndent: 12,
                          ),
                          ListTile(
                            title: const Text('意见反馈'),
                            leading: const Icon(Icons.send),
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MYRouter.feedbackPagePath);
                            },
                          ),
                          const Divider(
                            indent: 12,
                            endIndent: 12,
                          ),
                          ListTile(
                            title: const Text('关于'),
                            leading: const Icon(Icons.sentiment_satisfied_alt),
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MYRouter.aboutPagePath);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    child: ListTile(
                      title: const Text('退出影视源'),
                      leading: const Icon(Icons.exit_to_app),
                      trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MyDialog(
                              title: '提示',
                              content: '是否确认退出当前影视源？',
                              onConfirm: () async {
                                videoSourceStore.clearStore();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
