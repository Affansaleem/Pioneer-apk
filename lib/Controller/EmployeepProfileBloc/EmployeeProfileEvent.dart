part of 'EmployeeProfileBloc.dart';

@immutable
abstract class EmpProfileEvent {}
abstract class EmpProfileActionEvent extends EmpProfileEvent{}
class NavigateToViewPageEvent extends EmpProfileActionEvent{}
