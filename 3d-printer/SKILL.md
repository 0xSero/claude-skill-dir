# 3D Printer Management Expert (Ender-3 Focused)

Expert in 3D printer management, GCode manipulation, slicing, remote printer control via SSH, and Ender-3 specific operations. Specializes in monitoring prints, troubleshooting issues, optimizing settings, and automating common 3D printing workflows.

## When to use this skill

- Working with GCode files
- Slicing 3D models
- Controlling Ender-3 printer remotely
- Monitoring print progress via SSH
- Troubleshooting print failures
- Optimizing printer settings
- Managing print queue
- Analyzing print quality
- Maintaining printer calibration
- Automating printer workflows

## Core Expertise

### GCode Fundamentals

#### Understanding GCode
```gcode
; GCode is the language of 3D printers
; Comments start with semicolon

; Movement commands
G0 X10 Y10 Z5 F3000    ; Rapid move to position (X,Y,Z) at speed F
G1 X50 Y50 E10 F1500   ; Linear move with extrusion

; Temperature
M104 S200              ; Set hotend temperature (don't wait)
M109 S200              ; Set hotend temperature and wait
M140 S60               ; Set bed temperature (don't wait)
M190 S60               ; Set bed temperature and wait

; Fan control
M106 S255              ; Fan on at full speed (0-255)
M107                   ; Fan off

; Motor control
M84                    ; Disable steppers
G28                    ; Home all axes
G28 X Y                ; Home X and Y only

; Position
G90                    ; Absolute positioning
G91                    ; Relative positioning
G92 E0                 ; Reset extruder position
```

#### Common GCode Patterns
```gcode
; ===== START GCODE =====
G28                    ; Home all axes
M140 S60               ; Start heating bed
M104 S200              ; Start heating hotend
M190 S60               ; Wait for bed temp
M109 S200              ; Wait for hotend temp
G92 E0                 ; Reset extruder
G1 Z2.0 F3000          ; Move Z up
G1 X10 Y10 F5000       ; Move to start position
G1 Z0.3 F3000          ; Move down to printing height

; Draw purge line
G1 X200 E15 F1500      ; Purge line
G92 E0                 ; Reset extruder
; ===== END START GCODE =====

; ===== END GCODE =====
M104 S0                ; Turn off hotend
M140 S0                ; Turn off bed
G91                    ; Relative positioning
G1 E-2 F2700           ; Retract filament
G1 Z10                 ; Raise Z
G90                    ; Absolute positioning
G28 X Y                ; Home X and Y
M84                    ; Disable motors
; ===== END GCODE =====
```

### GCode Analysis and Modification

#### GCode Parser
```python
import re
from typing import Dict, List, Tuple

class GCodeParser:
    """Parse and analyze GCode files"""

    def __init__(self, filepath: str):
        self.filepath = filepath
        self.lines = []
        self.stats = {}
        self.load_file()

    def load_file(self):
        """Load GCode file"""
        with open(self.filepath, 'r') as f:
            self.lines = [line.strip() for line in f.readlines()]

    def analyze(self) -> Dict:
        """Analyze GCode file"""
        stats = {
            'total_lines': len(self.lines),
            'movement_lines': 0,
            'extrusion_distance': 0,
            'print_time_estimate': 0,
            'filament_used': 0,
            'max_temp_hotend': 0,
            'max_temp_bed': 0,
            'layer_count': 0,
        }

        current_e = 0
        layers = set()

        for line in self.lines:
            # Strip comments
            if ';' in line:
                comment = line.split(';', 1)[1].strip()
                # Extract slicer info from comments
                if 'LAYER:' in comment:
                    layers.add(comment)
                if 'TIME:' in comment:
                    # Extract time estimate
                    pass

            line = line.split(';')[0].strip()
            if not line:
                continue

            # Movement
            if line.startswith('G0') or line.startswith('G1'):
                stats['movement_lines'] += 1

                # Extract E value (extrusion)
                e_match = re.search(r'E([\d.]+)', line)
                if e_match:
                    e_value = float(e_match.group(1))
                    if e_value > current_e:
                        stats['extrusion_distance'] += (e_value - current_e)
                    current_e = e_value

            # Temperature
            if line.startswith('M104') or line.startswith('M109'):
                temp_match = re.search(r'S(\d+)', line)
                if temp_match:
                    temp = int(temp_match.group(1))
                    stats['max_temp_hotend'] = max(stats['max_temp_hotend'], temp)

            if line.startswith('M140') or line.startswith('M190'):
                temp_match = re.search(r'S(\d+)', line)
                if temp_match:
                    temp = int(temp_match.group(1))
                    stats['max_temp_bed'] = max(stats['max_temp_bed'], temp)

        stats['layer_count'] = len(layers)
        stats['filament_used'] = stats['extrusion_distance']

        return stats

    def modify_temperatures(self, hotend_temp: int = None, bed_temp: int = None):
        """Modify temperatures in GCode"""
        modified_lines = []

        for line in self.lines:
            modified = line

            # Modify hotend temp
            if hotend_temp and ('M104' in line or 'M109' in line):
                modified = re.sub(r'S\d+', f'S{hotend_temp}', line)

            # Modify bed temp
            if bed_temp and ('M140' in line or 'M190' in line):
                modified = re.sub(r'S\d+', f'S{bed_temp}', line)

            modified_lines.append(modified)

        return modified_lines

    def extract_layer(self, layer_num: int) -> List[str]:
        """Extract specific layer from GCode"""
        in_layer = False
        layer_lines = []

        for line in self.lines:
            if f';LAYER:{layer_num}' in line:
                in_layer = True
            elif f';LAYER:{layer_num + 1}' in line:
                break

            if in_layer:
                layer_lines.append(line)

        return layer_lines

    def save(self, output_path: str, lines: List[str] = None):
        """Save modified GCode"""
        lines = lines or self.lines

        with open(output_path, 'w') as f:
            f.write('\n'.join(lines))
```

### Ender-3 Remote Control via SSH

#### SSH Connection Setup
```bash
# Connect to printer running OctoPrint/Klipper
ssh pi@printer.local

# Or with IP
ssh pi@192.168.1.100

# Set up SSH key for passwordless access
ssh-copy-id pi@printer.local
```

#### OctoPrint API Control
```python
import requests
from typing import Optional

class OctoPrintController:
    """Control OctoPrint via API"""

    def __init__(self, host: str, api_key: str):
        self.host = host.rstrip('/')
        self.api_key = api_key
        self.headers = {
            'X-Api-Key': api_key,
            'Content-Type': 'application/json'
        }

    def get_status(self) -> dict:
        """Get printer status"""
        response = requests.get(
            f"{self.host}/api/printer",
            headers=self.headers
        )
        return response.json()

    def get_temperature(self) -> dict:
        """Get current temperatures"""
        status = self.get_status()
        return {
            'hotend': status['temperature']['tool0']['actual'],
            'bed': status['temperature']['bed']['actual'],
            'hotend_target': status['temperature']['tool0']['target'],
            'bed_target': status['temperature']['bed']['target'],
        }

    def get_job_status(self) -> dict:
        """Get current print job status"""
        response = requests.get(
            f"{self.host}/api/job",
            headers=self.headers
        )
        job = response.json()

        return {
            'state': job['state'],
            'progress': job['progress']['completion'],
            'print_time': job['progress']['printTime'],
            'print_time_left': job['progress']['printTimeLeft'],
            'file': job['job']['file']['name'] if job['job']['file'] else None
        }

    def start_print(self):
        """Start print job"""
        requests.post(
            f"{self.host}/api/job",
            headers=self.headers,
            json={'command': 'start'}
        )

    def pause_print(self):
        """Pause print job"""
        requests.post(
            f"{self.host}/api/job",
            headers=self.headers,
            json={'command': 'pause', 'action': 'pause'}
        )

    def cancel_print(self):
        """Cancel print job"""
        requests.post(
            f"{self.host}/api/job",
            headers=self.headers,
            json={'command': 'cancel'}
        )

    def send_gcode(self, commands: list):
        """Send GCode commands"""
        requests.post(
            f"{self.host}/api/printer/command",
            headers=self.headers,
            json={'commands': commands}
        )

    def home_axes(self, axes: str = 'xyz'):
        """Home printer axes"""
        axes_str = ' '.join(axes.upper())
        self.send_gcode([f'G28 {axes_str}'])

    def set_temperatures(self, hotend: int = None, bed: int = None):
        """Set temperatures"""
        commands = []
        if hotend is not None:
            commands.append(f'M104 S{hotend}')
        if bed is not None:
            commands.append(f'M140 S{bed}')
        if commands:
            self.send_gcode(commands)

    def upload_file(self, filepath: str):
        """Upload GCode file to OctoPrint"""
        with open(filepath, 'rb') as f:
            files = {'file': f}
            response = requests.post(
                f"{self.host}/api/files/local",
                headers={'X-Api-Key': self.api_key},
                files=files
            )
        return response.json()
```

### Klipper Integration

#### Klipper Commands via SSH
```bash
# Connect to Klipper
ssh pi@printer.local

# Send commands via Moonraker API
curl -X POST http://printer.local/printer/gcode/script \
  -H "Content-Type: application/json" \
  -d '{"script":"G28"}'

# Get printer status
curl http://printer.local/printer/info

# Emergency stop
curl -X POST http://printer.local/printer/emergency_stop
```

#### Klipper Python Client
```python
import requests

class KlipperController:
    """Control Klipper via Moonraker API"""

    def __init__(self, host: str):
        self.host = host.rstrip('/')

    def send_gcode(self, gcode: str):
        """Send GCode command"""
        response = requests.post(
            f"{self.host}/printer/gcode/script",
            json={"script": gcode}
        )
        return response.json()

    def get_status(self):
        """Get printer status"""
        response = requests.get(f"{self.host}/printer/objects/query")
        return response.json()

    def emergency_stop(self):
        """Emergency stop"""
        requests.post(f"{self.host}/printer/emergency_stop")

    def get_temperatures(self):
        """Get current temperatures"""
        response = requests.get(
            f"{self.host}/printer/objects/query?heater_bed&extruder"
        )
        data = response.json()['result']['status']

        return {
            'hotend': data['extruder']['temperature'],
            'bed': data['heater_bed']['temperature'],
            'hotend_target': data['extruder']['target'],
            'bed_target': data['heater_bed']['target'],
        }
```

### Slicing Integration

#### PrusaSlicer/SuperSlicer CLI
```bash
# Slice a file
prusa-slicer --export-gcode \
  --load config.ini \
  --output output.gcode \
  model.stl

# With custom settings
prusa-slicer --export-gcode \
  --load config.ini \
  --layer-height 0.2 \
  --fill-density 20% \
  --support-material \
  --output output.gcode \
  model.stl
```

#### Cura CLI
```bash
# Slice with Cura
CuraEngine slice \
  -v \
  -j printer_settings.def.json \
  -o output.gcode \
  -l model.stl
```

### Print Monitoring

#### Monitor Script
```python
import time
from datetime import datetime

class PrintMonitor:
    """Monitor print progress"""

    def __init__(self, controller):
        self.controller = controller
        self.start_time = None

    def start_monitoring(self, check_interval: int = 30):
        """Monitor print until completion"""
        self.start_time = datetime.now()
        print("Starting print monitoring...")

        while True:
            try:
                status = self.controller.get_job_status()
                temps = self.controller.get_temperature()

                if status['state'] == 'Printing':
                    progress = status['progress']
                    time_left = status['print_time_left']

                    print(f"\rProgress: {progress:.1f}% | "
                          f"Hotend: {temps['hotend']:.1f}°C | "
                          f"Bed: {temps['bed']:.1f}°C | "
                          f"Time left: {time_left//60:.0f}m",
                          end='', flush=True)

                elif status['state'] == 'Operational':
                    print("\n✓ Print completed!")
                    break

                elif status['state'] == 'Error':
                    print("\n❌ Print failed!")
                    break

                time.sleep(check_interval)

            except KeyboardInterrupt:
                print("\nMonitoring stopped")
                break
            except Exception as e:
                print(f"\n⚠️  Error: {e}")
                time.sleep(check_interval)
```

### Ender-3 Specific Settings

#### Ender-3 Recommended Settings
```ini
; Ender-3 Profile
[printer]
printer_model = Ender-3
bed_size = 220x220mm
print_height = 250mm
nozzle_diameter = 0.4mm

[temperatures]
pla_hotend = 200-210
pla_bed = 60
petg_hotend = 230-240
petg_bed = 80
abs_hotend = 240-250
abs_bed = 100

[speeds]
print_speed = 50mm/s
travel_speed = 150mm/s
first_layer_speed = 20mm/s
infill_speed = 60mm/s

[quality]
layer_height = 0.2mm        # Standard
layer_height_fine = 0.12mm   # High quality
layer_height_draft = 0.28mm  # Fast draft

[retraction]
retraction_distance = 5mm
retraction_speed = 40mm/s
```

#### Calibration Scripts
```bash
#!/bin/bash
# Ender-3 Calibration Helper

echo "=== Ender-3 Calibration ==="
echo ""

# 1. Bed Leveling
echo "1. Bed Leveling"
echo "Commands to send:"
echo "  G28          - Home all axes"
echo "  M211 S0      - Disable software endstops"
echo "  G1 Z0        - Move to Z=0"
echo "  # Manually adjust bed at each corner"
echo ""

# 2. E-steps calibration
echo "2. E-steps Calibration"
echo "Current E-steps:"
echo "  M503         - Check current E-steps (look for M92 E...)"
echo ""
echo "Calibration:"
echo "  1. Mark filament 120mm from extruder"
echo "  2. G91; G1 E100 F100   - Extrude 100mm"
echo "  3. Measure remaining distance"
echo "  4. New E-steps = current * (100 / actual_extruded)"
echo "  5. M92 E[new_value]    - Set new E-steps"
echo "  6. M500                - Save to EEPROM"
echo ""

# 3. PID Tuning
echo "3. PID Tuning"
echo "Hotend:"
echo "  M303 E0 S200 C8  - PID tune hotend to 200°C"
echo "  M301 P... I... D...  - Set values from tuning"
echo "  M500                  - Save"
echo ""
echo "Bed:"
echo "  M303 E-1 S60 C8  - PID tune bed to 60°C"
echo "  M304 P... I... D...  - Set values"
echo "  M500                  - Save"
echo ""

# 4. Z-offset
echo "4. Z-offset Calibration"
echo "  G28          - Home"
echo "  G1 Z0        - Move to Z=0"
echo "  # Use paper to adjust until slight friction"
echo "  M851 Z-x.xx  - Set offset (negative value)"
echo "  M500         - Save"
```

## Resources

The `resources/` directory contains:
- Ender-3 configuration profiles
- Common GCode scripts
- Calibration guides
- Troubleshooting guides
- Material settings database

## Scripts

The `scripts/` directory contains:
- `analyze-gcode.py` - Analyze GCode files
- `monitor-print.py` - Monitor print progress
- `send-to-printer.sh` - Upload and start print
- `calibrate-ender3.sh` - Calibration wizard
- `timelapse.sh` - Create print timelapse

## Hooks

The `hooks/` directory contains:
- Pre-print validation hooks
- Print completion notification hooks
- Failure detection hooks

## Agents

The `agents/` directory contains:
- `gcode-optimizer` - Optimize GCode for quality/speed
- `print-monitor` - Intelligent print monitoring
- `failure-detector` - Detect print failures
- `maintenance-reminder` - Remind about maintenance tasks

## Common Workflows

### 1. Slice and Print
```bash
# Slice model
prusa-slicer --export-gcode --load config.ini --output model.gcode model.stl

# Analyze
python analyze-gcode.py model.gcode

# Upload to printer
scp model.gcode pi@printer.local:/home/pi/.octoprint/uploads/

# Start print via API
curl -X POST http://printer.local/api/files/local/model.gcode \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{"command": "select", "print": true}'

# Monitor
python monitor-print.py
```

### 2. Remote Temperature Control
```python
from octoprint_controller import OctoPrintController

printer = OctoPrintController("http://printer.local", "YOUR_API_KEY")

# Preheat for PLA
printer.set_temperatures(hotend=200, bed=60)

# Check temperatures
temps = printer.get_temperature()
print(f"Hotend: {temps['hotend']}°C / {temps['hotend_target']}°C")
print(f"Bed: {temps['bed']}°C / {temps['bed_target']}°C")
```

### 3. Emergency Stop
```bash
# Via SSH
ssh pi@printer.local "curl -X POST http://localhost/printer/emergency_stop"

# Or via Python
from klipper_controller import KlipperController
klipper = KlipperController("http://printer.local")
klipper.emergency_stop()
```

## Troubleshooting Guide

### Common Issues

**Print not sticking to bed:**
- Re-level bed
- Clean bed with IPA
- Increase bed temperature
- Reduce first layer speed
- Increase first layer height slightly

**Stringing/oozing:**
- Increase retraction distance
- Increase retraction speed
- Lower printing temperature
- Increase travel speed

**Layer shifting:**
- Check belt tension
- Reduce print speed
- Check for mechanical obstructions
- Verify stepper driver current

**Under-extrusion:**
- Calibrate E-steps
- Check for clogs
- Increase temperature
- Check filament diameter setting

## Integration with Other Skills

- Works with `/python-dev/` for scripting
- Integrates with `/automater/` for workflow automation
- Complements `/system-manager/` for documentation
- Supports `/data-reporter/` for print analytics

## Safety Notes

- Never leave prints unattended
- Ensure proper ventilation
- Keep fire extinguisher nearby
- Monitor temperatures
- Regular maintenance prevents issues
- Emergency stop should be easily accessible

## Notes

- SSH access requires printer running OctoPrint/Klipper
- API keys should be kept secure
- Regular calibration improves print quality
- Keep firmware updated
- Document successful settings
- Join Ender-3 community for tips
