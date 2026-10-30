import json
import os
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops

root = Path(__file__).resolve().parent.parent
pairs = [
    (
        'web-orbs-carousel-1440x900.png',
        'flutter-orbs-carousel-1440x900.png',
        'diff-orbs-carousel-1440x900.png',
    ),
    (
        'web-orbs-carousel-390x844.png',
        'flutter-orbs-carousel-390x844.png',
        'diff-orbs-carousel-390x844.png',
    ),
]
results = {}
for web_name, flutter_name, diff_name in pairs:
    web = Image.open(root / 'reference' / 'parity' / web_name).convert('RGB')
    flutter = Image.open(root / 'reference' / 'parity' / flutter_name).convert('RGB')
    if web.size != flutter.size:
        flutter = flutter.resize(web.size)
    a = np.asarray(web, dtype=np.int16)
    b = np.asarray(flutter, dtype=np.int16)
    delta = np.abs(a - b)
    channel = delta.mean(axis=2)
    results[web_name] = {
        'size': list(web.size),
        'mean_abs_channel': round(float(delta.mean()), 3),
        'p99_abs_channel': round(float(np.percentile(delta, 99)), 3),
        'changed_pixels_over_8': round(
            float((delta.max(axis=2) > 8).mean()), 4
        ),
        'mean_abs_channel_4x_downsample': round(
            float(
                np.asarray(
                    ImageChops.difference(web, flutter).resize(
                        (max(1, web.width // 4), max(1, web.height // 4)),
                        Image.Resampling.BOX,
                    )
                ).mean()
            ),
            3,
        ),
        'centroid_delta': [
            round(float(np.argwhere(channel > 8)[:, 1].mean()), 2)
            if (channel > 8).any()
            else None,
            round(float(np.argwhere(channel > 8)[:, 0].mean()), 2)
            if (channel > 8).any()
            else None,
        ],
    }
    diff = ImageChops.difference(web, flutter)
    amplified = diff.point(lambda value: min(255, value * 4))
    amplified.save(root / 'reference' / 'parity' / diff_name)
    print(web_name, json.dumps(results[web_name]))

(root / 'reference' / 'parity' / 'carousel-metrics.json').write_text(
    json.dumps(results, indent=2) + '\n', encoding='utf-8'
)

limit = float(os.environ.get('CAROUSEL_MAX_MEAN', '5'))
worst = max(item['mean_abs_channel'] for item in results.values())
if worst > limit:
    print(
        f'Carousel parity mean {worst:.3f}/255 exceeds {limit:.3f}/255',
        file=sys.stderr,
    )
    sys.exit(1)
