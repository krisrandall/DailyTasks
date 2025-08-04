# Daily Tasks - Gamify Your Healthy Habits

An app and widget to gamify daily healthy habits by turning your media consumption into trackable, rewarding daily tasks.

Perfect for maintaining consistency with:
- 🧘 **Yoga practice** - Follow along with your video collection daily
- 💪 **Core strengthening** - Never skip your workout routine
- 🧠 **Meditation** - Build a sustainable mindfulness practice  
- 📚 **Educational content** - Make learning a daily habit
- 🎵 **Music practice** - Stay consistent with lessons or exercises

## ✨ Features

### 🎯 **Two Task Types**
- **Sequential**: Automatically plays the next video/audio in your collection
- **Choose**: Browse thumbnails and pick what you want to experience today

### 📱 **Three Experience Modes**
- **Mobile App**: Full-featured interface for managing and completing tasks
- **Desktop Widget**: Compact quick-access view for your computer
- **Android TV**: Optimized for big screen with remote control navigation

### 🏆 **Gamification Elements**
- Daily progress tracking with visual completion indicators
- Automatic midnight reset for fresh daily goals
- Separate required vs. optional task categories
- Celebration animations when tasks are completed

### 🎨 **Smart Media Management**
- Supports video (MP4, MOV, AVI, MKV, WebM, M4V, 3GP)
- Supports audio (MP3, WAV, M4A, AAC, OGG, FLAC, WMA)
- Automatic file discovery from device folders
- Built-in media player with seek controls

## 🚀 How It Works

1. **Set up your media**: Download videos/audio to folders on your device
2. **Create tasks**: Link each healthy habit to a media folder
3. **Choose your style**: Sequential for structured routines, or Choose for variety
4. **Mark as required or optional**: Focus on your must-dos vs. nice-to-haves
5. **Complete daily**: Tap tasks to play media and automatically mark as complete
6. **Track progress**: Watch your completion rate and maintain streaks

## 📥 Getting Your Media

### YouTube Content
Use [youtube-dl-pro](https://snapcraft.io/install/youtube-dl-pro/pop) to download playlists:

```bash
# Install youtube-dl-pro (Linux/Mac)
snap install youtube-dl-pro

# Download a playlist to your device
youtube-dl-pro -o "~/Videos/Yoga/%(title)s.%(ext)s" [PLAYLIST_URL]
```

### Organizing Your Files
Create folders for each habit:
```
/storage/emulated/0/
  ├── Videos/
  │   ├── Yoga/
  │   ├── CoreStrength/
  │   └── Meditation/
  └── Music/
      └── Lessons/
```

## 📱 Installation

### Android Mobile App

#### Option 1: Build from Source
```bash
# Clone the repository
git clone git@github.com:krisrandall/DailyTasks.git
cd daily_tasks

# Install dependencies
flutter pub get

# Build and install
flutter build apk --release
flutter install
```

#### Option 2: Download APK
1. Go to the [Releases](../../releases) page
2. Download the latest `daily-tasks.apk`
3. Enable "Install from Unknown Sources" in Android Settings
4. Open the APK file to install

### Android Widget

*** NOT YET IMPLEMENTED ***

**After installing the main app:**

1. **Long press** on your home screen
2. Select **"Widgets"**
3. Find **"Daily Tasks"** in the widget list
4. **Drag** the widget to your desired location
5. The widget will show a compact view of your pending tasks
6. **Tap items** in the widget to mark complete or **tap the expand icon** to open the full app

### Desktop Widget (Linux/Windows/Mac)

```bash
# Build for desktop
flutter build [linux/windows/macos] --release

# Run the widget version
flutter run --release -d [desktop] --dart-define=WIDGET_MODE=true
```

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.0+
- Android Studio (for Android builds)
- Xcode (for iOS builds, Mac only)

### Quick Start
```bash
# Clone and setup
git clone [your-repo-url]
cd daily_tasks
flutter pub get

# Run in development
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📖 Usage Examples

### Morning Yoga Routine
- **Task Name**: "Morning Yoga"
- **Type**: Sequential (plays next video each day)
- **Required**: Daily
- **Folder**: `/storage/emulated/0/Videos/Yoga/`

### Core Strengthening
- **Task Name**: "Core Workout" 
- **Type**: Choose (pick based on energy level)
- **Required**: Daily
- **Folder**: `/storage/emulated/0/Videos/CoreStrength/`

### Evening Meditation
- **Task Name**: "Wind Down Meditation"
- **Type**: Sequential
- **Required**: Optional
- **Folder**: `/storage/emulated/0/Audio/Meditation/`

## 🔐 Permissions

The app requires storage permissions to:
- Read your media files
- Save task configuration and progress
- Access folders you specify for each task




---

**Made with ❤️ for building consistent, healthy habits through gamification.**

---

Made by Claude.ai, with this initial prompt:

```
I'd like you to develop a particular software system

It will be a Flutter app
We will also have a widget interface so there is a widget that can be on the desktop for Android or iOS
We will also have an Android TV interface

All of this within the same Flutter app 

You need to think about what files we will have

We want it well structured, but as simple as approprate

The program itself is quite simple - 
There is a list of "Daily Tasks"
this can just be a configuration file in the first instance
Each "daily task" needs to have access to a folder of media (either videos or audio) on the device - that is a configuration item, the name of the on-device folder
There should be a name for the item
And there should be a task type --- of either "sequence" or "choose"

So - a dailyTask has these properties : {
 name: String
 onDeviceMediaFolder: String (or something else more specific),
 taskType:  enum of sequence or choose,
 lastMediaFilePlayed: String (probably),
 required: enum of daily or optional 
}

and the functionality is very simple 

The UI should show a list of all of the dailyTasks, showing the name, and a check-list to the left of each name
The idea is that when you click on the item, it will play the next media file -- in the case of "sequence", this is just the next one in an ordered list (the order in which they appear in a directory listing) , in the case of "choose" it should show a screen with thumbnails and a title under each media file available , and clicking on it will play that media file
This is for the entries where required=daily
When required=optional it will look different - these optional ones are listed after the daily ones - and it doesn't have an empty check-list box to the left, instead a circle icon (there are 3 icons that will be used, an unchecked checkbox, a checked checkbox, and the .. circle unchecked checkbox .. you pick appropriate Icons, and I will change the later if needed)
For a required=optional, it will still show as the checked checkbox after the media is watched, same as required=daily

After midnight, all items that were checked change back to being unchecked for the next day
Playing a media file causes that item to become checked

do you have any questions , or are you ready to give me the general overview (list files) of the plan for making the system ?
```