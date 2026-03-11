# Cloud Dissolve Animation

A refined, cloud-like dissolve animation widget for Flutter applications. This package provides smooth blur, float, scale, and fade-out effects, designed specifically for elegant deletion animations in lists, complex UI components, or any standard widget.

![Cloud Dissolve Animation Demo](https://github.com/user-attachments/assets/268e8388-3f00-4778-bcc0-e2b4428c0631)


## Features

- **Progressive Blur**: Applies high-sigma Gaussian blur that smoothly spreads out.
- **Float and Scale**: Gently lifts and expands the widget during dissolution.
- **Smooth Opacity Transition**: Ensures a clean fade-out effect.
- **Auto-Collapse**: Automatically closes the freed space, ideal for dynamic list structures.
- **Overlay Rendering**: Renders at the top layer, allowing effects to safely exceed widget boundaries.
- **Highly Configurable**: Control duration, animation curves, and spatial behaviors.
- **Ready-to-use Wrappers**: Includes `DeletableItemWrapper` for boilerplate-free implementation in lists.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  cloud_dissolve_animation: ^<latest_version>
```

## Usage

### Basic Implementation

Wrap any widget in a `CloudDissolveAnimation` to trigger the effect immediately upon rendering or as part of a state change.

```dart
import 'package:cloud_dissolve_animation/cloud_dissolve_animation.dart';

CloudDissolveAnimation(
  onComplete: () {
    // Handle the removal of the item from your data source
    setState(() => items.removeAt(index));
  },
  child: MyWidget(),
)
```

### Implementing in Lists (Recommended)

For `ListView` or similar dynamic sequences, use the provided `DeletableItemWrapper` to handle state and animation synchronization automatically.

```dart
import 'package:cloud_dissolve_animation/cloud_dissolve_animation.dart';

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];

    return DeletableItemWrapper(
      key: ValueKey(item.id),
      isDeleting: item.isDeleting,
      onDeleteComplete: () {
        setState(() => items.removeWhere((i) => i.id == item.id));
      },
      child: ListTile(
        title: Text(item.title),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() => item.isDeleting = true);
          },
        ),
      ),
    );
  },
)
```

### Disabling Size Collapse

If the animation occurs within a fixed-size container (not part of a dynamically sizing list), you can disable the shrink behavior to prevent the layout from shifting natively.

```dart
CloudDissolveAnimation(
  shrinkSize: false,
  duration: const Duration(milliseconds: 800),
  onComplete: () => debugPrint('Dissolved!'),
  child: MyFixedWidget(),
)
```

## Configuration

### CloudDissolveAnimation Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | Required | The target widget to dissolve. |
| `onComplete` | `VoidCallback?` | `null` | Callback executed after the animation sequence finishes. |
| `duration` | `Duration` | `500ms` | The total length of the animation. |
| `curve` | `Curve` | `easeOutCubic` | The animation curve for pacing. |
| `shrinkSize` | `bool` | `true` | Dictates whether the container collapses its boundaries post-animation. |

### DeletableItemWrapper Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | Required | The target widget to monitor or wrap. |
| `isDeleting` | `bool` | `false` | A state flag. Setting this to `true` initiates the dissolve animation. |
| `onDeleteComplete` | `VoidCallback?` | `null` | Callback executed after the dissolve effectively concludes. |

## Animation Breakdown

The dissolve effect synchronously orchestrates five distinct visual transitions:

| Visual Effect | Value Range | Temporal Range | Description |
|---|---|---|---|
| **Blur** | 0 to 30 sigma | 0% – 80% | Progressive Gaussian blur spread. |
| **Float** | 0 to -30px | 0% – 80% | Upward vertical translation. |
| **Scale** | 1.0 to 1.15 | 0% – 70% | Slight outward radial expansion. |
| **Opacity** | 1.0 to 0.0 | 15% – 100% | Linear fade to full transparency. |
| **Size** | 1.0 to 0.0 | 20% – 100% | Structural space collapse (if enabled). |

## Requirements

- Flutter SDK: `3.10` or higher
- Dart SDK: `3.0` or higher

## License

This project is licensed under the MIT License. Reference [LICENSE](LICENSE) for exact terms.
