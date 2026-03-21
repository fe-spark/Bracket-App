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
        // print(_);
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
    final bottomNavigationInset = MediaQuery.paddingOf(context).bottom;
    // final String? token = profileStore.data?.userToken;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.5),
                        width: 4,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(30),
                      // color: Theme.of(context).primaryColor,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Row(
                        children: [
                          // Avatar / Icon
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
                          // Text Info
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '当前视频源',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    getDomainName(
                                        videoSourceStore.data?.actived ?? ''),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10, vertical: 4),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white.withValues(alpha: 0.2),
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                //   child: const Text(
                                //     '已连接',
                                //     style: TextStyle(
                                //       color: Colors.white,
                                //       fontSize: 12,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('观看历史'),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history,
                                  color: Colors.purple, size: 22),
                            ),
                            trailing: Icon(Icons.chevron_right,
                                color: Theme.of(context).disabledColor),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MYRouter.historyPagePath);
                            },
                          ),
                          const Divider(
                            indent: 70,
                            endIndent: 16,
                          ),
                          ListTile(
                            title: const Text('系统主题'),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.palette_outlined,
                                  color: Colors.blue, size: 22),
                            ),
                            trailing: Icon(Icons.chevron_right,
                                color: Theme.of(context).disabledColor),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, MYRouter.themePagePath);
                            },
                          ),
                          const Divider(
                            indent: 70,
                            endIndent: 16,
                          ),
                          ListTile(
                            title: const Text('意见反馈'),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send_outlined,
                                  color: Colors.red, size: 22),
                            ),
                            trailing: Icon(Icons.chevron_right,
                                color: Theme.of(context).disabledColor),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MYRouter.feedbackPagePath);
                            },
                          ),
                          const Divider(
                            indent: 70,
                            endIndent: 16,
                          ),
                          ListTile(
                            title: const Text('关于'),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sentiment_satisfied_alt,
                                  color: Colors.amber, size: 22),
                            ),
                            trailing: Icon(Icons.chevron_right,
                                color: Theme.of(context).disabledColor),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      title: const Text(
                        '退出影视源',
                        style: TextStyle(color: Colors.red),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout,
                            color: Colors.red, size: 22),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: Theme.of(context).disabledColor),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MyDialog(
                              title: '提示',
                              content: '是否确认退出当前影视源？',
                              onConfirm: () async {
                                await videoSourceStore.clearStore();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: bottomNavigationInset),
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
