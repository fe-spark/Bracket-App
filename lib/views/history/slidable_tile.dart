import '/plugins.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const SlidableTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var histryStore = context.watch<HistoryStore>();
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: ValueKey(data['id']),

      // The start action pane is the one at the left or the top side.
      endActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(
          onDismissed: () {
            histryStore.deleteHistoryForId(data['id']);
          },
        ),

        // All actions are defined in the children parameter.
        children: [
          // const SizedBox(
          //   width: 8,
          // ),
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            // borderRadius: BorderRadius.circular(8),
            onPressed: (actionContext) {
              showDialog(
                context: actionContext,
                builder: (BuildContext context) {
                  return MyDialog(
                    title: '提示',
                    content: '是否删除播放记录',
                    onConfirm: () async {
                      histryStore.deleteHistoryForId(data['id']);
                    },
                  );
                },
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            // label: '删除',
          ),
          // SlidableAction(
          //   onPressed: (_) {},
          //   backgroundColor: const Color(0xFF21B7CA),
          //   foregroundColor: Colors.white,
          //   icon: Icons.share,
          //   label: 'Share',
          // ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      // startActionPane: ActionPane(
      //   motion: const ScrollMotion(),
      //   children: [
      //     SlidableAction(
      //       // An action can be bigger than the others.
      //       flex: 2,
      //       onPressed: (_) {},
      //       backgroundColor: const Color(0xFF7BC043),
      //       foregroundColor: Colors.white,
      //       icon: Icons.archive,
      //       label: 'Archive',
      //     ),
      //     SlidableAction(
      //       onPressed: (_) {},
      //       backgroundColor: const Color(0xFF0392CF),
      //       foregroundColor: Colors.white,
      //       icon: Icons.save,
      //       label: 'Save',
      //     ),
      //   ],
      // ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).focusColor),
        child: ListTile(
          // minVerticalPadding: 12,
          tileColor: Theme.of(context).colorScheme.surface,
          onTap: () {
            Navigator.of(context).pushNamed(
              MYRouter.detailPagePath,
              arguments: {
                'id': data["id"],
              },
            );
          },
          title: Text(
            data['name'] ?? '',
          ),
          subtitle: Text(
            "上次观看至：${DateScope.formatDuration(data['startAt'])}",
            style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 4,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right_outlined),
          leading: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
            width: 100,
            height: double.infinity,
            child: PosterImage(
              imageUrl: data['picture']?.toString(),
            ),
          ),
        ),
      ),
    );
  }
}
