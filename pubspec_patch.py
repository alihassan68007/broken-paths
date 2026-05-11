import yaml

with open('pubspec.yaml', 'r') as f:
    data = yaml.safe_load(f)

if 'flutter' not in data:
    data['flutter'] = {}

data['flutter']['assets'] = [
    'assets/data/',
    'assets/images/backgrounds/',
    'assets/audio/'
]

with open('pubspec.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False, sort_keys=False)
