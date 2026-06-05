import 'package:flutter/material.dart';

enum StreakStatus { active, atRisk, broken, none }

class InsightsState {
  final int totalMinutes;
  final int totalPages;
  final int totalBooks;
  final int currentStreak;
  final int longestStreak;
  final List<StreakDay> streakHistory;
  final StreakStatus streakStatus;
  final List<Achievement> achievements;
  final List<GenreStat> genreDistribution;
  final List<MonthlySummary> monthlyMinutes;
  final int ytdMinutes;
  final int ytdPages;

  InsightsState({
    required this.totalMinutes,
    required this.totalPages,
    required this.totalBooks,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakHistory,
    required this.streakStatus,
    required this.achievements,
    required this.genreDistribution,
    required this.monthlyMinutes,
    required this.ytdMinutes,
    required this.ytdPages,
  });
}

class StreakDay {
  final DateTime date;
  final bool hasActivity;
  final int durationSeconds;

  StreakDay({
    required this.date,
    required this.hasActivity,
    required this.durationSeconds,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String targetDescription;
  final IconData icon;
  final bool unlocked;
  final double progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDescription,
    required this.icon,
    required this.unlocked,
    required this.progress,
  });
}

class GenreStat {
  final String genre;
  final int bookCount;
  final double percentage;

  GenreStat({
    required this.genre,
    required this.bookCount,
    required this.percentage,
  });
}

class MonthlySummary {
  final int month;
  final int year;
  final int minutes;
  final int pages;

  MonthlySummary({
    required this.month,
    required this.year,
    required this.minutes,
    required this.pages,
  });
}
