# Cloud Dissolve Animation

A dreamy cloud-like dissolve animation widget for Flutter. Creates beautiful blur, float, scale, and fade-out effects — perfect for deletion animations in lists, messages, or any widget.

![Cloud Dissolve Animation](https://github.com/user-attachments/assets/c955a777-8590-4b1b-887d-05e095fbb837)

## ✨ Features

- **Cloud-like blur spreading** — Progressive gaussian blur with high sigma
- **Float upward** — Widget gently floats up during dissolution
- **Scale expansion** — Slight outward expansion for a spreading cloud effect
- **Smooth fade-out** — Elegant opacity transition
- **Size collapse** — Original space smoothly closes (ideal for lists)
- **Overlay-based rendering** — Animation renders at the top layer, allowing blur to spread freely beyond widget bounds
- **Configurable** — Duration, curve, and shrink behavior
- **Ready-to-use wrapper** — `DeletableItemWrapper` for easy list item deletion

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cloud_dissolve_animation: ^0.0.1
```

## 🚀 Usage

### Basic Usage

```dart
import 'package:cloud_dissolve_animation/cloud_dissolve_animation.dart';

CloudDissolveAnimation(
  onComplete: () {
    // Remove item from data source
    setState(() => items.removeAt(index));
  },
  child: MyWidget(),
)
```

### With DeletableItemWrapper (Recommended for Lists)

```dart
import 'package:cloud_dissolve_animation/cloud_dissolve_animation.dart';

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return DeletableItemWrapper(
      key: ValueKey(items[index].id),
      isDeleting: items[index].isDeleting,
      onDeleteComplete: () {
        setState(() => items.removeWhere((i) => i.id == items[index].id));
      },
      child: ListTile(
        title: Text(items[index].title),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() => items[index].isDeleting = true);
          },
        ),
      ),
    );
  },
)
```

### Without Size Collapse

If you're using the animation in a fixed-size container (not a list), disable the shrink:

```dart
CloudDissolveAnimation(
  shrinkSize: false, // Don't collapse the space
  duration: Duration(milliseconds: 800),
  onComplete: () => print('Dissolved!'),
  child: MyFixedWidget(),
)
```

## ⚙️ Configuration

### CloudDissolveAnimation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | Required | The widget to dissolve |
| `onComplete` | `VoidCallback?` | `null` | Called when animation completes |
| `duration` | `Duration` | `500ms` | Total animation duration |
| `curve` | `Curve` | `easeOutCubic` | Animation curve |
| `shrinkSize` | `bool` | `true` | Whether to collapse the widget's space |

### DeletableItemWrapper

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | Required | The widget to wrap |
| `isDeleting` | `bool` | `false` | Set to `true` to start dissolving |
| `onDeleteComplete` | `VoidCallback?` | `null` | Called when animation completes |

## 🎬 Animation Breakdown

The dissolve effect combines 5 synchronized animations:

| Effect | Range | Timing | Description |
|--------|-------|--------|-------------|
| **Blur** | 0 → 30 sigma | 0% – 80% | Progressive gaussian blur |
| **Opacity** | 1.0 → 0.0 | 15% – 100% | Smooth fade out |
| **Scale** | 1.0 → 1.15 | 0% – 70% | Slight outward expansion |
| **Float** | 0 → -30px | 0% – 80% | Upward movement |
| **Size** | 1.0 → 0.0 | 20% – 100% | Space collapse |

## 📋 Requirements

- Flutter 3.10+
- Dart 3.0+

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
