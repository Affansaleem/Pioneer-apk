import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/constants/AnimatedTextPopUp.dart';
import 'package:project/constants/AppColor_constants.dart';
import 'package:project/constants/globalObjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../No_internet/no_internet.dart';
import '../../admin/adminDashboard/screen/adminMain.dart';
import '../../employee/empDashboard/models/user_repository.dart';
import '../../employee/empDashboard/screens/employeeMain.dart';
import '../../introduction/bloc/bloc_internet/internet_bloc.dart';
import '../../introduction/bloc/bloc_internet/internet_state.dart';
import '../bloc/loginBloc/loginEvents.dart';
import '../bloc/loginBloc/loginStates.dart';
import '../bloc/loginBloc/loginbloc.dart';
import 'halfCircleClipper.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

enum UserType { employee, admin }

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController addToCartPopUpAnimationController;

  @override
  void initState() {
    addToCartPopUpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    super.initState();
  }

  @override
  void dispose() {
    addToCartPopUpAnimationController.dispose();
    super.dispose();
  }

  UserType? _selectedUserType = UserType.employee;
  final _passwordController = TextEditingController();
  final _CoorporateIdController = TextEditingController();
  final _UserController = TextEditingController();
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _isButtonPressed = false;
  static const String KEY_LOGIN = "Login";
  final UserRepository userRepository = UserRepository();
  String? corporateId;

  void handleAdminLogin(
    String enteredCorporateID,
    String enteredUsername,
    String enteredPassword,
    String enteredRole,
  ) async {
    try {
      final employeeData = await userRepository.getData(
        corporateId: enteredCorporateID,
        username: enteredUsername,
        password: enteredPassword,
        role: enteredRole,
      );

      if (employeeData.isNotEmpty) {
        _saveAdminDataToSharedPreferences(enteredUsername, enteredCorporateID);
        _loginAsAdmin();
      } else {
        showPopupWithMessageFailed(
            "User not found!"); // Show "User not found" message
      }
    } catch (e) {
      showPopupWithMessageFailed(
          "User not found!"); // Show "User not found" message
    }
  }

  void _saveAdminDataToSharedPreferences(
      String username, String corporateId) async {
    final sharedPref = await SharedPreferences.getInstance();
    GlobalObjects.adminusername = username;
    GlobalObjects.adminCorpId = corporateId;
    sharedPref.setString('admin_username', username);
    sharedPref.setString('admin_corporateId', corporateId);
  }

  void _handleEmployeeLogin(
    String enteredCorporateID,
    String enteredUsername,
    String enteredPassword,
    String enteredRole,
  ) async {
    try {
      final employeeData = await userRepository.getData(
        corporateId: enteredCorporateID,
        username: enteredUsername,
        password: enteredPassword,
        role: enteredRole,
      );

      if (employeeData.isNotEmpty) {
        final cardNo = employeeData[0].cardNo;
        final empCode = employeeData[0].empCode;
        final employeeId = employeeData[0].empId;
        _saveCardNoToSharedPreferences(cardNo, empCode, employeeId);
        _loginAsEmployee();
      } else {
        showPopupWithMessageFailed(
            "User not found!"); // Show "User not found" message
      }
    } catch (e) {
      showPopupWithMessageFailed(
          "User not found!"); // Show "User not found" message
    }
  }

  void _loginAsEmployee() async {
    // await _successScaffoldMessage(context, "Login Successful");
    showPopupWithMessageSuccess("Login Successful");
    await Future.delayed(Duration(seconds: 3));

    Navigator.pushReplacement(
        context,
        PageTransition(
            child: const EmpMainPage(), type: PageTransitionType.rightToLeft));
  }

  void _saveCardNoToSharedPreferences(
      String cardNo, String empCode, int employeeId) async {
    final sharedPrefEmp = await SharedPreferences.getInstance();
    sharedPrefEmp.setString('cardNo', cardNo);
    sharedPrefEmp.setString('empCode', empCode);
    sharedPrefEmp.setInt('employee_id', employeeId);
    GlobalObjects.empCode = empCode;
    GlobalObjects.empId = employeeId;
  }

  void _loginAsAdmin() async {
    showPopupWithMessageSuccess("Login Successful");
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
        context,
        PageTransition(
            child: const AdminMainPage(),
            type: PageTransitionType.rightToLeft));
  }

  void showPopupWithMessageFailed(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return addToCartPopUpFailed(addToCartPopUpAnimationController, message);
      },
    );
  }

  void showPopupWithMessageSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return addToCartPopUpSuccess(
            addToCartPopUpAnimationController, message);
      },
    );
  }

  void showPopupWithMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return addToCartPopUpNoCrossMessage(
          addToCartPopUpAnimationController,
          message
        );
      },
    );
  }

  void _onLoginButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isButtonPressed = true;
      });

      await Future.delayed(const Duration(seconds: 1));
      var sharedPref = await SharedPreferences.getInstance();
      sharedPref.setBool(KEY_LOGIN, true);

      final enteredCorporateID = _CoorporateIdController.text;
      final enteredUsername = _UserController.text;
      final enteredPassword = _passwordController.text;
      String enteredRole = '';

      // Set the role based on the selected user type
      if (_selectedUserType == UserType.employee) {
        enteredRole = 'employee';
        addToCartPopUpAnimationController.forward();

        // Delay for a few seconds and then reverse the animation
        Timer(const Duration(seconds: 3), () {
          addToCartPopUpAnimationController.reverse();
          Navigator.pop(context);
        });
      } else if (_selectedUserType == UserType.admin) {
        enteredRole = 'admin';
        addToCartPopUpAnimationController.forward();

        Timer(const Duration(seconds: 3), () {
          addToCartPopUpAnimationController.reverse();
          Navigator.pop(context);
        });
      }
      sharedPref.setString('role', enteredRole);
      // saving corporateId
      final sharedPrefEmp = await SharedPreferences.getInstance();
      sharedPrefEmp.setString('corporate_id', enteredCorporateID);
      sharedPrefEmp.setString('user_name', enteredUsername);
      sharedPrefEmp.setString('password', enteredPassword);

      if (_selectedUserType == UserType.employee) {
        corporateId = _CoorporateIdController.text;
        _handleEmployeeLogin(
          corporateId!,
          enteredUsername,
          enteredPassword,
          enteredRole,
        );
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool('isLoggedIn', true);
        sharedPref.setBool('isEmployee', true);
      } else if (_selectedUserType == UserType.admin) {
        corporateId = _CoorporateIdController.text;

        GlobalObjects.adminCorpId = corporateId;
        handleAdminLogin(
          corporateId!,
          enteredUsername,
          enteredPassword,
          enteredRole,
        );
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool('isLoggedIn', true);
        sharedPref.setBool('isEmployee', false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid corporate ID, username, or password.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isButtonPressed = false;
      });
    } else {
      addToCartPopUpAnimationController.forward();

      // Delay for a few seconds and then reverse the animation
      Timer(const Duration(seconds: 2), () {
        addToCartPopUpAnimationController.reverse();
        Navigator.pop(context);
      });
      showPopupWithMessage("Please filled out all fields!");
    }
  }

  bool isInternetLost = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetStates>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is InternetLostState) {
          // Set the flag to true when internet is lost
          isInternetLost = true;
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              PageTransition(
                child: NoInternet(),
                type: PageTransitionType.rightToLeft,
              ),
            );
          });
        } else if (state is InternetGainedState) {
          // Check if internet was previously lost
          if (isInternetLost) {
            // Navigate back to the original page when internet is regained
            Navigator.pop(context);
          }
          isInternetLost = false; // Reset the flag
        }
      },
      builder: (context, state) {
        if (state is InternetGainedState) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  ClipPath(
                    clipper: HalfCircleClipper(),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width,
                        color: AppColors.primaryColor,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Text(
                              "PIONEER TIME ATTENDANCE",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 25, // Adjust the size as needed
                                color:
                                    Colors.white, // Adjust the color as needed
                              ),
                            ),
                          ],
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.65
                          : MediaQuery.of(context).size.width * 0.55,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, -2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              BlocBuilder<SignInBloc, SignInState>(
                                builder: (BuildContext context, state) {
                                  if (state is SignInNotValidState) {
                                    return Text(
                                      state.message,
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          letterSpacing: 0,
                                          fontSize: 15,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              Text(
                                "LOG IN",
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _CoorporateIdController,
                                decoration: InputDecoration(
                                  labelText: 'Corporate Id',
                                  suffixIcon: Image.asset(
                                    'assets/icons/username.png',
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Coorporate ID';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _UserController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  suffixIcon:
                                      Image.asset('assets/icons/profile.png'),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter UserName';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                onChanged: (value) {
                                  BlocProvider.of<SignInBloc>(context).add(
                                    SignInTextChangedEvent(
                                      password: _passwordController.text,
                                    ),
                                  );
                                },
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon:
                                      Image.asset('assets/icons/password.png'),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("Show Password"),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Checkbox(
                                      value: !_obscureText,
                                      onChanged: (value) {
                                        setState(() {
                                          _obscureText = !value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUserType = UserType.employee;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Radio<UserType>(
                                            value: UserType.employee,
                                            groupValue: _selectedUserType,
                                            onChanged: (UserType? value) {
                                              setState(() {
                                                _selectedUserType = value!;
                                              });
                                            },
                                          ),
                                          const Text('Employee'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16), // Adjust the spacing between Employee and Admin
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUserType = UserType.admin;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),

                                      child: Row(
                                        children: [
                                          Radio<UserType>(
                                            value: UserType.admin,
                                            groupValue: _selectedUserType,
                                            onChanged: (UserType? value) {
                                              setState(() {
                                                _selectedUserType = value!;
                                              });
                                            },
                                          ),
                                          const Text('Admin'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              BlocBuilder<SignInBloc, SignInState>(
                                builder: (BuildContext context, state) {
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                        const Size(250, 50),
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              AppColors.primaryColor),
                                      elevation: MaterialStateProperty.all(3),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.grey),
                                    ),
                                    onPressed: () {
                                      _onLoginButtonPressed();
                                    },
                                    child: _isButtonPressed
                                        ? const SizedBox(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: Colors.white,
                                            ),
                                            width: 15.0,
                                            height: 15.0,
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
