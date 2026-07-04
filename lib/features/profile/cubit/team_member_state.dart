import '../data/models/team_member_model.dart';

abstract class TeamMemberState {}

class TeamMemberInitial extends TeamMemberState {}

class TeamMemberLoading extends TeamMemberState {}

class TeamMembersLoaded extends TeamMemberState {
  final List<TeamMember> teamMembers;

  TeamMembersLoaded(this.teamMembers);
}

class TeamMemberError extends TeamMemberState {
  final String message;

  TeamMemberError(this.message);
}

class TeamMemberActionSuccess extends TeamMemberState {
  final String message;

  TeamMemberActionSuccess(this.message);
}
