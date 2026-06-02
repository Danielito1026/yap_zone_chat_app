import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yap_zone/models/chat_message.dart';
import 'package:transparent_image/transparent_image.dart';

// A ChatMessageBubble for showing a single chat message on the ChatScreen.
class ChatMessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const ChatMessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.type,
    required this.message,
    required this.isMe,
    required this.sendTime,
    required this.showSendTime,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const ChatMessageBubble.next({
    super.key,
    required this.type,
    required this.message,
    required this.isMe,
    required this.sendTime,
    required this.showSendTime,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  final DateTime sendTime;
  final bool showSendTime;

  final MessageType type;

  // Controls how the ChatMessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String timestamp = timeago.format(sendTime);

    return Stack(
      children: [
        if (userImage != null && !isMe)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: isMe ? null : const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        username!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMe
                            ? [
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                              ]
                            : [theme.colorScheme.surfaceContainerHigh, theme.colorScheme.surfaceContainerHighest],
                            begin: Alignment.centerLeft,
                            end:AlignmentGeometry.centerRight
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.2,
                          ), // Shadow color
                          spreadRadius: 2, // Extends the shadow further
                          blurRadius: 10, // Blurs the edges of the shadow
                          offset: const Offset(
                            0,
                            4,
                          ), // Shifts shadow horizontally (x) and vertically (y)
                        ),
                      ],
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    // Set some reasonable constraints on the width of the
                    // message bubble so it can adjust to the amount of text
                    // it should show.
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 12,
                    ),
                    child: type == MessageType.text
                        ? Text(
                            message,
                            style: TextStyle(
                              // Add a little line spacing to make the text look nicer
                              // when multilined.
                              height: 1.3,
                            ),
                            softWrap: true,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: message,
                            ),
                          ),
                  ),

                  if (showSendTime)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        timestamp,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
