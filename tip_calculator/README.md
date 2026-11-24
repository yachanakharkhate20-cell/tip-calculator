# Tip Calculator (Flutter)

A beginner-friendly Tip Calculator. Enter a bill, pick a tip percentage with a slider, split it between people, and see the tip and totals update instantly. Currency: Indian Rupee (₹).

```
tip_calculator/
├── lib/
│   ├── main.dart        # App entry point + theme
│   └── tip_page.dart    # The screen: UI, state and calculations
├── pubspec.yaml
└── README.md
```

---

## 1. Setup (step by step)

1. **Install Flutter** from https://docs.flutter.dev/get-started/install and make sure `flutter doctor` shows no major errors.
2. **Install VS Code** and add the extensions **Flutter** and **Dart**.
3. **Copy this folder** (`tip_calculator`) to your computer.
4. **Generate the platform folders** (Android / iOS / web). This project contains only the Dart code, so open a terminal inside the `tip_calculator` folder and run:
   ```bash
   flutter create .
   ```
   This adds `android/`, `ios/`, etc. It will **not** overwrite `lib/main.dart`, `lib/tip_page.dart` or `pubspec.yaml`. (If it replaces `lib/main.dart` with the default counter app, copy the provided `main.dart` back.)
5. **Download dependencies:**
   ```bash
   flutter pub get
   ```

## 2. Run in VS Code

1. `File → Open Folder…` and choose `tip_calculator`.
2. Start an Android emulator, iOS simulator, or plug in a phone with USB debugging. You can also pick **Chrome** or **Windows** as the device.
3. Click the device name in the bottom-right corner of VS Code and select your device.
4. Open `lib/main.dart` and press **F5** (or `Run → Start Debugging`).
5. While the app runs, edit code and save the file. Press **r** in the terminal, or let VS Code hot reload, to see changes instantly.

Terminal alternative: `flutter run`

---

## 3. Test cases

Enter these values in the app and compare with the expected results.

| # | Bill | Tip % | People | Tip | Total | Tip / Person | Total / Person |
|---|------|-------|--------|-----|-------|--------------|----------------|
| 1 | 1000 | 10 | 4 | ₹100.00 | ₹1100.00 | ₹25.00 | ₹275.00 |
| 2 | 500 | 20 | 1 | ₹100.00 | ₹600.00 | ₹100.00 | ₹600.00 |
| 3 | 850 | 15 | 3 | ₹127.50 | ₹977.50 | ₹42.50 | ₹325.83 |
| 4 | 1200 | 0 | 6 | ₹0.00 | ₹1200.00 | ₹0.00 | ₹200.00 |
| 5 | *(empty)* | 10 | 2 | ₹0.00 | ₹0.00 | ₹0.00 | ₹0.00 |
| 6 | 1000 | 30 | 5 | ₹300.00 | ₹1300.00 | ₹60.00 | ₹260.00 |

(Values are rounded to two decimals with `toStringAsFixed(2)`.)

**Error-handling checks**

- Leave the bill empty → everything shows ₹0.00.
- Try typing `-`, letters or a second `.` → they are blocked by the input filter.
- Tap **−** when people is 1 → nothing happens (button is disabled).
- Type just `.` → treated as invalid, so the bill is ₹0.00 and the app does not crash.

---

## 4. Important Flutter widgets and functions explained

| Widget / function | What it does here |
|---|---|
| `StatefulWidget` | A screen whose data changes. `TipPage` is stateful because the bill, tip % and people count change. |
| `setState(() { ... })` | Tells Flutter "my data changed, rebuild the screen". Called whenever the user changes an input. |
| `TextField` | The box where the bill is typed. `onChanged` fires on every keystroke. |
| `TextEditingController` | Lets you read or control the text of a `TextField`. Disposed in `dispose()` to free memory. |
| `keyboardType` | `numberWithOptions(decimal: true)` shows the number keypad. |
| `inputFormatters` | Filters what can be typed. Here it allows only digits and one decimal point (so no negative numbers). |
| `double.tryParse()` | Converts text to a number, and returns `null` (instead of crashing) if the text is invalid. `?? 0` supplies the fallback. |
| `Slider` | Selects a value between `min` and `max`. `divisions: 30` snaps it to whole percents. |
| `IconButton` | A tappable icon, used for **+** and **−**. Passing `onPressed: null` disables it. |
| `Card` | A rounded, elevated surface that groups related content. |
| `Container` | A box you can give padding, colors, gradients and rounded corners. |
| `Column` / `Row` | Place children vertically / horizontally. |
| `Padding` and `SizedBox` | Add space inside a widget / empty gaps between widgets. |
| `Expanded` | Makes a child share the available space (used for the two small result cards). |
| `FittedBox` | Shrinks big numbers so they never overflow on small screens. |
| `SingleChildScrollView` | Lets the screen scroll when the keyboard is open or the screen is small. |
| Getters (`get tipAmount => ...`) | Calculated values that are recomputed from the current state every time they are read, so results are always in sync. |
| `toStringAsFixed(2)` | Formats a number with exactly two decimal places. |

### How the calculation flows

1. The user types, drags the slider, or taps **+ / −**.
2. The handler calls `setState()`.
3. Flutter rebuilds the screen. The UI reads the getters (`tipAmount`, `totalAmount`, `tipPerPerson`, `totalPerPerson`), which use the latest state.
4. The new values appear instantly.

```dart
double get tipAmount      => bill * tipPercent / 100;
double get totalAmount    => bill + tipAmount;
double get tipPerPerson   => tipAmount / _safePeople;   // _safePeople is never below 1
double get totalPerPerson => totalAmount / _safePeople;
```
