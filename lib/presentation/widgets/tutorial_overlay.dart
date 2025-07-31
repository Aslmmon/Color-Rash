// lib/presentation/widgets/tutorial_overlay.dart
import 'package:color_rash/domain/game_notifier.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/domain/tutorial_page_content.dart';
import 'package:color_rash/presentation/theme/app_colors.dart';
import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/widgets/game_button.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialOverlay extends StatefulWidget {
  final GameNotifier gameNotifier;

  const TutorialOverlay({super.key, required this.gameNotifier});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define your tutorial content here. This makes the widget reusable!
  // <--- MODIFIED: Use AppStrings constants
  static final List<TutorialPageContent> _tutorialPages = [
    TutorialPageContent(
      title: AppStrings.tutorialWelcomeTitle,
      body: AppStrings.tutorialWelcomeBody,
      visualWidget: Icon(
        Icons.star,
        size: 80,
        color: AppColors.incorrectTapColor,
      ),
    ),
    TutorialPageContent(
      title: AppStrings.tutorialMatchColorTitle,
      body: AppStrings.tutorialMatchColorBody,
      visualWidget: Icon(
        Icons.sports_volleyball_outlined,
        size: 80,
        color: AppColors.incorrectTapColor,
      ),
    ),
    TutorialPageContent(
      title: AppStrings.tutorialTimingKeyTitle,
      body: AppStrings.tutorialTimingKeyBody,
      visualWidget: Icon(
        Icons.timer_3_sharp,
        size: 80,
        color: AppColors.incorrectTapColor,
      ),
    ),
    TutorialPageContent(
      title: AppStrings.tutorialSurviveScoreTitle,
      body: AppStrings.tutorialSurviveScoreBody,
      visualWidget: Icon(
        Icons.sports_score,
        size: 80,
        color: AppColors.incorrectTapColor,
      ),
    ),
    TutorialPageContent(
      title: AppStrings.tutorialGetReadyTitle,
      // Use string interpolation for kMaxLevel
      body: AppStrings.tutorialGetReadyBody.replaceAll(
        '{level}',
        AppConstants.kMaxLevel.toString(),
      ),
      visualWidget: Icon(
        Icons.rocket_launch,
        size: 80,
        color: AppColors.incorrectTapColor,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _tutorialPages[index];
                  return _buildTutorialPage(context, page);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.kDefaultPadding,
              ),
              child: Column(
                children: [
                  _buildPageIndicators(),
                  const SizedBox(height: AppConstants.kDefaultPadding),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(BuildContext context, TutorialPageContent page) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.kLargePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lilitaOne().copyWith(
              fontSize: 36,
              color: AppColors.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.kDefaultPadding),
          if (page.imagePath != null)
            Image.asset(page.imagePath!, height: 150, fit: BoxFit.contain)
          else if (page.visualWidget != null)
            page.visualWidget!,
          const SizedBox(height: AppConstants.kDefaultPadding),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit().copyWith(
              fontSize: 18,
              color: AppColors.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tutorialPages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color:
                _currentPage == index
                    ? AppColors.accentColor
                    : AppColors.secondaryTextColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentPage > 0)
          GameButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            width: 100,
            height: 50,
            color: AppColors.incorrectTapColor.withOpacity(0.8),
            borderRadius: 12,
            child: Text(
              AppStrings.tutorialButtonBack,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.buttonTextColor,
              ),
            ),
          ),
        GameButton(
          onPressed: () {
            if (_currentPage < _tutorialPages.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            } else {
              widget.gameNotifier.markTutorialSeen();
            }
          },
          width: _currentPage == _tutorialPages.length - 1 ? 160 : 100,
          height: 50,
          color: AppColors.accentColor,
          borderRadius: 12,
          child: Text(
            _currentPage == _tutorialPages.length - 1
                ? AppStrings.tutorialButtonGotItLetSPlay
                : AppStrings.tutorialButtonNext,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.buttonTextColor),
          ),
        ),
      ],
    );
  }
}
