import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/social_person.dart';

class ProfileItem extends StatelessWidget {
  final SocialPerson? person;
  final Function? onUserSelected;

  const ProfileItem({Key? key, this.person, this.onUserSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 4,
        color: Colors.deepPurple,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: TextButton(
          onPressed: () {
            onUserSelected!(person);
          },
          child: Wrap(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _profilePic(),
                            _usernameContainer(),
                          ],
                        )
                      ],
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

  Widget _profilePic() {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        width: 64,
        child: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.5),
          backgroundImage:
              CachedNetworkImageProvider(person!.personProfilePicURL!),
        ),
      ),
    );
  }

  Widget _usernameContainer() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, right: 3),
                    child: Text(
                      person!.personUsername!,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'LatoBold',
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
