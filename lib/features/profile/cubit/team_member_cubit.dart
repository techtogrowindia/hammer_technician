import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/profile_repository.dart';
import 'team_member_state.dart';

class TeamMemberCubit extends Cubit<TeamMemberState> {
  final ProfileRepository repository;

  TeamMemberCubit(this.repository) : super(TeamMemberInitial());

  Future<void> loadTeamMembers() async {
    emit(TeamMemberLoading());
    try {
      final list = await repository.getTeamMembers();
      emit(TeamMembersLoaded(list));
    } catch (e) {
      emit(TeamMemberError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> createTeamMember({
    required String name,
    required String mobile,
    required String aadharNumber,
  }) async {
    emit(TeamMemberLoading());
    try {
      await repository.createTeamMember(
        name: name,
        mobile: mobile,
        aadharNumber: aadharNumber,
      );
      emit(TeamMemberActionSuccess('Team member created successfully!'));
      await loadTeamMembers();
    } catch (e) {
      emit(TeamMemberError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> deleteTeamMember(dynamic id) async {
    emit(TeamMemberLoading());
    try {
      await repository.deleteTeamMember(id);
      emit(TeamMemberActionSuccess('Team member deleted successfully!'));
      await loadTeamMembers();
    } catch (e) {
      emit(TeamMemberError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
