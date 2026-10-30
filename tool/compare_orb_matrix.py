import json
import os
import sys
from pathlib import Path

import numpy as np
from PIL import Image

root = Path(__file__).resolve().parent.parent
web_dir = Path(
    os.environ.get(
        'ORBS_WEB_DIR',
        root / 'reference' / 'captures' / 'orbs-web',
    )
)
flutter_dir = root / 'reference' / 'captures' / 'orbs'
out_path = root / 'reference' / 'parity' / 'orb-matrix.json'

if not web_dir.is_dir():
    print(
        f'Missing web captures at {web_dir}; run the web parity harness first.',
        file=sys.stderr,
    )
    sys.exit(2)

rows = []
for web_path in sorted(web_dir.glob('*.png')):
    name = web_path.name
    flutter_path = flutter_dir / name
    if not flutter_path.exists():
        rows.append({'name': name, 'missing': True})
        continue
    theme = 'light' if '-light-' in name else 'dark'
    background = (253, 253, 253, 255) if theme == 'light' else (10, 10, 10, 255)
    web = Image.open(web_path).convert('RGBA')
    base = Image.new('RGBA', web.size, background)
    base.alpha_composite(web)
    web_rgb = base.convert('RGB')
    flutter = Image.open(flutter_path).convert('RGB')
    if web_rgb.size != flutter.size:
        flutter = flutter.resize(web_rgb.size, Image.Resampling.LANCZOS)
    a = np.asarray(web_rgb, dtype=np.int16)
    b = np.asarray(flutter, dtype=np.int16)
    delta = np.abs(a - b)
    rows.append(
        {
            'name': name,
            'state': name.split('-')[0],
            'size': int(name.split('-')[1]),
            'theme': theme,
            't': float(name.rsplit('-', 1)[1][:-4]),
            'mean': round(float(delta.mean()), 4),
            'p99': round(float(np.percentile(delta, 99)), 3),
            'changed_over_8': round(
                float((delta.max(axis=2) > 8).mean()), 5
            ),
            'web_size': list(web_rgb.size),
            'flutter_size': list(flutter.size),
        }
    )

measured = [row for row in rows if 'mean' in row]
summary = {
    'pairs': len(measured),
    'missing': [row['name'] for row in rows if row.get('missing')],
    'mean_abs_channel': round(
        float(np.mean([row['mean'] for row in measured])), 4
    ),
    'max_mean_abs_channel': round(
        float(max(row['mean'] for row in measured)), 4
    ),
    'mean_changed_over_8': round(
        float(np.mean([row['changed_over_8'] for row in measured])), 5
    ),
    'pairs_over_8_mean': sum(1 for row in measured if row['mean'] > 8),
    'pairs_over_16_mean': sum(1 for row in measured if row['mean'] > 16),
}

out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text(
    json.dumps({'summary': summary, 'rows': rows}, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(summary, indent=2))

limit = float(os.environ.get('ORBS_MAX_MEAN', '10'))
if summary['max_mean_abs_channel'] > limit:
    print(
        f"Orb matrix max mean {summary['max_mean_abs_channel']:.3f}/255 "
        f'exceeds {limit:.3f}/255',
        file=sys.stderr,
    )
    sys.exit(1)
