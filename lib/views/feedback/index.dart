import '/plugins.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _inputController = TextEditingController();
  String text = "";

  @override
  void initState() {
    _inputController.addListener(() {
      setState(() {
        text = _inputController.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('意见反馈')),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _inputController,
                    maxLines: 8,
                    maxLength: 200,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: '请输入您的宝贵意见...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                      counterText: '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                  onPressed: (text != '')
                      ? () {
                          setState(() {
                            text = "";
                          });
                          _inputController.clear();
                          const snackBar = SnackBar(
                            content: Text("提交成功"),
                            behavior: SnackBarBehavior.floating,
                          );
                          ScaffoldMessenger.of(context).removeCurrentSnackBar(
                            reason: SnackBarClosedReason.remove,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      : null,
                  child: const Text(
                    '提交反馈',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
