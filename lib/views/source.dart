import '/plugins.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _source = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static bool isURL(String s) =>
      RegExp(r"^((https|http|ftp|rtsp|mms)?:\/\/)[^\s]+").hasMatch(s);

  @override
  void dispose() {
    _source.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bracket'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final source = _source.text;
                if (_formKey.currentState?.validate() ?? false) {
                  final videoStore = context.read<VideoSourceStore>();
                  await videoStore.addSource(source);
                }
              },
              child: const Text(
                '开启观影体验',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Image(
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                      const SizedBox(height: 80),
                      Consumer<VideoSourceStore>(
                        builder: (context, videoStore, child) {
                          final history = videoStore.data?.source ?? [];
                          return LayoutBuilder(builder: (context, constraints) {
                            return Autocomplete<String>(
                              initialValue: TextEditingValue(text: _source.text),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (history.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return history.where((String option) {
                                  return option.contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                _source.text = selection;
                                // Selection only fills field (no direct confirm)
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 8.0,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: constraints.maxWidth,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxHeight: 250,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ListView.separated(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final String option =
                                                options.elementAt(index);
                                            return ListTile(
                                              dense: true,
                                              title: Text(
                                                option,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              fieldViewBuilder: (context, textController,
                                  focusNode, onFieldSubmitted) {
                                textController.addListener(() {
                                  _source.text = textController.text;
                                });
                                return TextFormField(
                                  controller: textController,
                                  focusNode: focusNode,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    labelText: '影视源',
                                    hintText: '输入地址或从下拉选择历史',
                                    prefixIcon: const Icon(Icons.link),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onPressed: () {
                                        if (!focusNode.hasFocus) {
                                          focusNode.requestFocus();
                                        }
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant
                                        .withOpacity(0.3),
                                  ),
                                  validator: (value) {
                                    if (!isURL(value ?? '')) {
                                      return '格式错误🙅';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    onFieldSubmitted();
                                  },
                                );
                              },
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
