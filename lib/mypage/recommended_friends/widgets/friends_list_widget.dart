import 'package:flutter/material.dart';
import '../recommended_friends_controller.dart';
import 'friend_item_widget.dart';

class FriendsListWidget extends StatelessWidget {
  final RecommendedFriendsController controller;

  const FriendsListWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return _buildLoadingState();
    }

    if (controller.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (controller.friends.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFriendsList();
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
          child: Text(
              controller.errorMessage,
              style: const TextStyle(color: Colors.red)
          )
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          controller.getTranslatedText('no_recommended_friends', '나를 추천한 친구가 없습니다'),
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFriendsListHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: controller.friends.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
                indent: 70,
              ),
              itemBuilder: (context, index) {
                final friend = controller.friends[index];
                return FriendItemWidget(friend: friend);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsListHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.getTranslatedText('recommended_friends_list', '추천한프렌즈'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '${controller.friends.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4169E1),
            ),
          ),
        ],
      ),
    );
  }
}