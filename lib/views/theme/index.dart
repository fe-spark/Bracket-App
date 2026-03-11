import '/plugins.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeStore themeStore = context.watch<ThemeStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统主题'),
      ),
      body: RadioGroup<String>(
        groupValue: themeStore.data,
        onChanged: (String? value) {
          if (value != null) {
            themeStore.setTheme(value);
          }
        },
        child: ListView(
          children: <Widget>[
            RadioListTile<String>(
              title: const Text('跟随系统'),
              value: ITheme.auto.value,
            ),
            RadioListTile<String>(
              title: const Text('暗黑模式'),
              value: ITheme.dark.value,
            ),
            RadioListTile<String>(
              title: const Text('明亮模式'),
              value: ITheme.light.value,
            )
          ],
        ),
      ),
    );
  }
}

abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
