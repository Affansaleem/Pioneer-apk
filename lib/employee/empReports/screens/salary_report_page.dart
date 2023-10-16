import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:project/constants/AppColor_constants.dart';
import 'package:project/employee/empReports/screens/salary_report_details_page.dart';


class EmpSalaryReportPage extends StatefulWidget {
  const EmpSalaryReportPage({super.key});

  @override
  State<EmpSalaryReportPage> createState() => _EmpSalaryReportPageState();
}

class _EmpSalaryReportPageState extends State<EmpSalaryReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salary Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor:
        AppColors.primaryColor, // Match the GPS Tracker Page's theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month),
                Text(
                  DateFormat('MMMM dd, yyyy').format(DateTime.now()), // Format the current date
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  // Handle button tap here

                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const EmpSalaryReportDetail(),),);

                },
                child:  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 24,
                        color: AppColors.navyBlue, // Match the GPS Tracker Page's theme
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Salary Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
