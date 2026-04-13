import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:hammer_app/core/colors/colors.dart';

class KycStepperScaffold extends StatelessWidget {
  final int activeStep;
  final List<bool> stepCompleted;
  final List<bool> stepError;
  final Widget stepContent;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLoading;
  final ScrollController? scrollController;

  const KycStepperScaffold({
    super.key,
    required this.activeStep,
    required this.stepCompleted,
    required this.stepError,
    required this.stepContent,
    required this.onBack,
    required this.onNext,
    required this.isLoading,
    this.scrollController,
  });

  Widget _buildStepIcon(int index) {
    if (stepError[index]) {
      return const Icon(Icons.error, color: Colors.red);
    }
    if (stepCompleted[index]) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryBlue,
        child: Icon(Icons.check, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: activeStep == index
          ? AppColors.primaryBlue
          : Colors.grey.shade300,
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: activeStep == index ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: activeStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && activeStep > 0) onBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryAmber,
              size: 20,
            ),
            onPressed: onBack,
          ),
          title: Text(
            activeStep == 7 ? "Review & Submit" : "Step ${activeStep + 1} of 8",
            style: const TextStyle(
              color: AppColors.primaryAmber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: EasyStepper(
                lineStyle: LineStyle(
                  lineLength: 30,
                  lineThickness: 2,
                  lineType: LineType.normal,
                  defaultLineColor: Colors.grey.shade300,
                  finishedLineColor: AppColors.primaryBlue,
                ),
                activeStep: activeStep,
                stepRadius: 18,
                showLoadingAnimation: false,
                enableStepTapping: false,
                activeStepBackgroundColor: Colors.transparent,
                activeStepBorderColor: AppColors.primaryBlue,
                activeStepTextColor: AppColors.primaryBlue,
                finishedStepBackgroundColor: AppColors.primaryBlue,
                unreachedStepBackgroundColor: const Color(0xFFF1F5F9),
                steps: [
                  EasyStep(customStep: _buildStepIcon(0), title: "Personal"),
                  EasyStep(customStep: _buildStepIcon(1), title: "Education"),
                  EasyStep(customStep: _buildStepIcon(2), title: "Services"),
                  EasyStep(
                    customStep: _buildStepIcon(3),
                    title: "Certificates",
                  ),
                  EasyStep(
                    customStep: _buildStepIcon(4),
                    title: "Firm/Company/Agency",
                  ),
                  EasyStep(customStep: _buildStepIcon(5), title: "Bank"),
                  EasyStep(customStep: _buildStepIcon(6), title: "Documents"),
                  EasyStep(customStep: _buildStepIcon(7), title: "Review"),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [stepContent, const SizedBox(height: 40)],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isLoading ? null : onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              activeStep < 7
                                  ? 'Continue to Next Step'
                                  : 'Confirm & Submit Application',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
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
