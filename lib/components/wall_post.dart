import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/comment.dart';
import 'package:social_media_app/components/comment_button.dart';
import 'package:social_media_app/components/like_button.dart';
import 'package:social_media_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike() {
    print('Like');
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document is FireBase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      // if the post is now liked, add user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, remove user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComemt(String commentText) {
    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() // remember to format this when displaying
    });
  }

  // show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Text Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);
              // clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),
          //post button
          TextButton(
            onPressed: () {
              // add comment
              addComemt(_commentTextController.text);
              //pop box
              Navigator.pop(context);
              // clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //wall post
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //message
              Text(widget.message),
              const SizedBox(height: 5),

              // user
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    ' - ',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //like
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  const SizedBox(height: 5),
                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              //comment
              Column(
                children: [
                  // comment button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),
                  const SizedBox(height: 5),
                  // like count
                  const Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          //coments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //show loading circle if no date yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                  shrinkWrap: true, // for mested lists
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    // get the comment
                    final commentData = doc.data() as Map<String, dynamic>;
                    // return the comment
                    return Comment(
                        text: commentData["CommentText"],
                        user: commentData["CommentedBy"],
                        time: formatDate(commentData["CommentTime"]));
                  }).toList());
            },
          )
        ],
      ),
    );
  }
}
