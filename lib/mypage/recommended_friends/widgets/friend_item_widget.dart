import 'package:flutter/material.dart';

class FriendItemWidget extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendItemWidget({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          _buildFriendName(),
          _buildReservationCount(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
        image: friend['photoUrl'] != null && friend['photoUrl'].toString().isNotEmpty
            ? DecorationImage(
          image: NetworkImage(friend['photoUrl']),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: friend['photoUrl'] == null || friend['photoUrl'].toString().isEmpty
          ? const Icon(Icons.person, color: Colors.grey, size: 20)
          : null,
    );
  }

  Widget _buildFriendName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            friend['name'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCount() {
    return Text(
      '${friend['reservationCount']}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4169E1),
      ),
    );
  }
}