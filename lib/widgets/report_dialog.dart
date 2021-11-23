import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class ReportDialog extends StatefulWidget {
  final SocialPerson? person;
  final SocialPost? post;

  ReportDialog(this.person, this.post);

  @override
  _ReportDialogPageState createState() =>
      _ReportDialogPageState();
}

class _ReportDialogPageState extends State<ReportDialog> {
  SocialPerson? _person;
  SocialPost? _post;

  final List<String> _items = <String>[
    REPORT_REASON_SPAM,
    REPORT_REASON_NUDITY,
    REPORT_REASON_HATE_SPEECH,
    REPORT_REASON_VIOLENCE,
    REPORT_REASON_SALE_OF_ILLEGAL_GOODS,
    REPORT_REASON_BULLYING,
    REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION,
    REPORT_REASON_SUICIDE,
    REPORT_REASON_EATING_DISORDERS,
    REPORT_REASON_SCAM,
    REPORT_REASON_FALSE_INFORMATION,
    REPORT_REASON_OTHER,
  ];

  final Map<String, String> _promptMap = {
    REPORT_REASON_SPAM: REPORT_REASON_SPAM_PROMPT,
    REPORT_REASON_NUDITY: REPORT_REASON_NUDITY_PROMPT,
    REPORT_REASON_HATE_SPEECH: REPORT_REASON_HATE_SPEECH_PROMPT,
    REPORT_REASON_VIOLENCE: REPORT_REASON_VIOLENCE_PROMPT,
    REPORT_REASON_SALE_OF_ILLEGAL_GOODS:
        REPORT_REASON_SALE_OF_ILLEGAL_GOODS_PROMPT,
    REPORT_REASON_BULLYING: REPORT_REASON_BULLYING_PROMPT,
    REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION:
        REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION_PROMPT,
    REPORT_REASON_SUICIDE: REPORT_REASON_SUICIDE_PROMPT,
    REPORT_REASON_EATING_DISORDERS: REPORT_REASON_EATING_DISORDERS_PROMPT,
    REPORT_REASON_SCAM: REPORT_REASON_SCAM_PROMPT,
    REPORT_REASON_FALSE_INFORMATION: REPORT_REASON_FALSE_INFORMATION_PROMPT,
    REPORT_REASON_OTHER: REPORT_REASON_OTHER_PROMPT,
  };

  OutlineInputBorder textBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.white.withOpacity(0.4)));

  String? dropdownValue = REPORT_REASON_SPAM;

  final textController = TextEditingController();

  String? _getCurrentValuePrompt(String? input) {
    return _promptMap[input!];
  }

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        insetPadding: EdgeInsets.all(16),
        backgroundColor: Colors.deepPurple,
        contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reportOption(),
              _reportDialogText("Why are you reporting?"),
              _reportDropdown(),
              _reportDialogText(
                  "Any additional comments on the issue? (Optional)"),
              _reportInput(),
              _reportButton()
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _post == null ? "Report User" : "Report Post",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'LatoBold',
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _reportDropdown() {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 12),
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Stack(
          children: [
            DropdownButton<String>(
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              iconSize: 28,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              isExpanded: true,
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              itemHeight: 56,
              value: null,
              items: _items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_getCurrentValuePrompt(value)!,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.deepPurple,
                          fontSize: 18)),
                );
              }).toList(),
            ),
            Container(
              height: 56,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getCurrentValuePrompt(dropdownValue)!,
                  style: TextStyle(
                      fontFamily: 'Lato', color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _reportInput() {
    return SizedBox(
      height: 156,
      child: Container(
        height: double.infinity,
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: false,
          maxLines: null,
          minLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: Colors.white.withOpacity(0.7),
          style:
              TextStyle(fontFamily: 'Lato', color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            border: textBorder,
            focusedBorder: textBorder,
            enabledBorder: textBorder,
            errorBorder: textBorder,
            disabledBorder: textBorder,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            hintText: "Type here",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 24),
      child: TextButton(
        onPressed: () {
          final UserSocialCubit userSocialCubit =
              BlocProvider.of<UserSocialCubit>(context);

          FocusScope.of(context).unfocus();

          userSocialCubit.sendReport(
              dropdownValue, textController.text, _post, _person);

          Navigator.pop(context);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
        child: Padding(
          padding: EdgeInsets.only(top: 12, bottom: 12),
          child: Center(
              child: Text(
            "Send Report",
            style: TextStyle(
              color: Colors.deepPurple,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          )),
        ),
      ),
    );
  }

  Widget _reportDialogText(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            color: Colors.white.withOpacity(0.4)),
      ),
    );
  }
}
