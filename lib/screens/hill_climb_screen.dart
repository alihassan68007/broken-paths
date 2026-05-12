import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import '../utils/constants.dart';

// --- MODELS FOR SELECTION ---

enum VehicleType {
  mehran(name: "Mehran", color: Colors.white, density: 0.8, torque: 800, wheelRadius: 0.7),
  cultus(name: "Cultus", color: Colors.blue, density: 1.0, torque: 1000, wheelRadius: 0.8),
  civic(name: "Civic", color: Colors.black, density: 1.2, torque: 1200, wheelRadius: 0.9);

  final String name;
  final Color color;
  final double density;
  final double torque;
  final double wheelRadius;

  const VehicleType({
    required this.name,
    required this.color,
    required this.density,
    required this.torque,
    required this.wheelRadius,
  });
}

enum TerrainType {
  city(name: "Smooth City", friction: 0.8, amplitude: 2.0, frequency: 20.0, color: Colors.grey),
  village(name: "Bumpy Village", friction: 0.6, amplitude: 5.0, frequency: 15.0, color: Colors.brown),
  mountains(name: "Extreme Mountains", friction: 0.4, amplitude: 10.0, frequency: 30.0, color: Colors.blueGrey);

  final String name;
  final double friction;
  final double amplitude;
  final double frequency;
  final Color color;

  const TerrainType({
    required this.name,
    required this.friction,
    required this.amplitude,
    required this.frequency,
    required this.color,
  });
}

// --- FLUTTER UI: PRE-GAME SELECTION ---

class HillClimbScreen extends StatefulWidget {
  const HillClimbScreen({Key? key}) : super(key: key);

  @override
  State<HillClimbScreen> createState() => _HillClimbScreenState();
}

class _HillClimbScreenState extends State<HillClimbScreen> {
  VehicleType selectedVehicle = VehicleType.mehran;
  TerrainType selectedTerrain = TerrainType.city;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    if (isPlaying) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: AppConstants.aspectRatio,
            child: GameWidget(
              game: HillClimbGame(
                vehicle: selectedVehicle,
                terrainType: selectedTerrain,
                onGameEnd: (coinsEarned) {
                  Provider.of<GameProvider>(context, listen: false).addCoins(coinsEarned);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      );
    }

    // Pre-game selection menu
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: AppConstants.aspectRatio,
          child: Container(
            color: AppColors.darkBackground,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Select Your Vehicle & Terrain', style: TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Vehicle Selection
                    Column(
                      children: [
                        const Text('Vehicle', style: TextStyle(color: AppColors.creamWhite, fontSize: 24)),
                        ...VehicleType.values.map((v) => RadioListTile<VehicleType>(
                          title: Text(v.name, style: TextStyle(color: v.color == Colors.black ? Colors.grey : v.color)),
                          value: v,
                          groupValue: selectedVehicle,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedVehicle = val);
                          },
                          activeColor: AppColors.gold,
                        )).toList(),
                      ],
                    ),
                    // Terrain Selection
                    Column(
                      children: [
                        const Text('Terrain', style: TextStyle(color: AppColors.creamWhite, fontSize: 24)),
                        ...TerrainType.values.map((t) => RadioListTile<TerrainType>(
                          title: Text(t.name, style: TextStyle(color: t.color)),
                          value: t,
                          groupValue: selectedTerrain,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedTerrain = val);
                          },
                          activeColor: AppColors.gold,
                        )).toList(),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => setState(() => isPlaying = true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: AppColors.forestGreen,
                  ),
                  child: const Text('Start Driving', style: TextStyle(fontSize: 24, color: AppColors.creamWhite)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FLAME FORGE2D GAME ---

class HillClimbGame extends Forge2DGame with HasKeyboardHandlerComponents {
  final VehicleType vehicle;
  final TerrainType terrainType;
  final Function(int) onGameEnd;

  late Car car;
  late EndlessTerrain terrainManager;
  int coinsEarned = 0;
  bool isGameOver = false;

  HillClimbGame({
    required this.vehicle,
    required this.terrainType,
    required this.onGameEnd,
  }) : super(zoom: 10, gravity: Vector2(0, 9.8));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedAspectRatioViewport(aspectRatio: AppConstants.aspectRatio);

    terrainManager = EndlessTerrain(terrainType: terrainType);
    await add(terrainManager);

    car = Car(position: Vector2(0, -10), vehicleType: vehicle);
    await add(car);

    camera.follow(car.chassis);

    // UI Buttons
    add(HudButton(
      button: CircleComponent(radius: 3, paint: Paint()..color = Colors.green),
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      onPressed: () => car.gas = true,
      onReleased: () => car.gas = false,
      position: Vector2.zero(),
    ));

    add(HudButton(
      button: CircleComponent(radius: 3, paint: Paint()..color = Colors.red),
      margin: const EdgeInsets.only(left: 20, bottom: 20),
      onPressed: () => car.brake = true,
      onReleased: () => car.brake = false,
      position: Vector2.zero(),
    ));

    add(CoinHud());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    terrainManager.checkAndGenerateTerrain(car.chassis.body.position.x);
  }

  void collectCoin(Coin coin) {
    coin.removeFromParent();
    coinsEarned += 10;
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    onGameEnd(coinsEarned);
  }
}

// --- ENDLESS TERRAIN GENERATION ---

class EndlessTerrain extends Component with HasGameRef<HillClimbGame> {
  final TerrainType terrainType;
  double lastGeneratedX = -20.0;
  final double chunkSize = 100.0;
  final List<TerrainChunk> chunks = [];

  EndlessTerrain({required this.terrainType});

  @override
  Future<void> onLoad() async {
    // Generate initial chunks
    await generateChunk();
    await generateChunk();
  }

  void checkAndGenerateTerrain(double carX) {
    if (carX + chunkSize > lastGeneratedX) {
      generateChunk();
    }
  }

  Future<void> generateChunk() async {
    final chunk = TerrainChunk(
      startX: lastGeneratedX,
      endX: lastGeneratedX + chunkSize,
      terrainType: terrainType,
    );
    chunks.add(chunk);
    await gameRef.add(chunk);

    // Add coins on this chunk
    for (double x = lastGeneratedX + 10; x < lastGeneratedX + chunkSize; x += 15) {
      double y = getTerrainY(x, terrainType) - 5; // Place above ground
      await gameRef.add(Coin(position: Vector2(x, y)));
    }

    lastGeneratedX += chunkSize;

    // Optional: cleanup old chunks far behind to save memory
    if (chunks.length > 5) {
      final oldChunk = chunks.removeAt(0);
      oldChunk.removeFromParent();
    }
  }

  static double getTerrainY(double x, TerrainType type) {
    return math.sin(x / type.frequency) * type.amplitude + math.cos(x / (type.frequency * 2)) * (type.amplitude / 2);
  }
}

class TerrainChunk extends BodyComponent<HillClimbGame> {
  final double startX;
  final double endX;
  final TerrainType terrainType;

  TerrainChunk({required this.startX, required this.endX, required this.terrainType});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.static,
    );
    final body = world.createBody(bodyDef);

    final shape = ChainShape();
    final List<Vector2> vertices = [];
    for (double x = startX; x <= endX; x += 2) {
      double y = EndlessTerrain.getTerrainY(x, terrainType);
      vertices.add(Vector2(x, y));
    }
    shape.createChain(vertices);

    final fixtureDef = FixtureDef(shape, friction: terrainType.friction, restitution: 0.1);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = terrainType.color..strokeWidth = 1.0..style = PaintingStyle.stroke;
    for (var fixture in body.fixtures) {
      if (fixture.shape is ChainShape) {
        final shape = fixture.shape as ChainShape;
        for (int i = 0; i < shape.vertexCount - 1; i++) {
          final v1 = shape.getVertex(i);
          final v2 = shape.getVertex(i + 1);
          canvas.drawLine(Offset(v1.x, v1.y), Offset(v2.x, v2.y), paint);
        }
      }
    }
  }
}

// --- CAR & PHYSICS ---

class Car extends Component with HasGameRef<HillClimbGame> {
  final Vector2 position;
  final VehicleType vehicleType;

  late BodyComponent chassis;
  late Wheel backWheel;
  late Wheel frontWheel;
  late WheelJoint backJoint;
  late WheelJoint frontJoint;

  bool gas = false;
  bool brake = false;

  Car({required this.position, required this.vehicleType});

  @override
  Future<void> onLoad() async {
    chassis = Chassis(position: position, vehicleType: vehicleType);
    await gameRef.add(chassis);

    backWheel = Wheel(position: position + Vector2(-1.5, 1), radius: vehicleType.wheelRadius);
    await gameRef.add(backWheel);

    frontWheel = Wheel(position: position + Vector2(1.5, 1), radius: vehicleType.wheelRadius);
    await gameRef.add(frontWheel);

    final jdBack = WheelJointDef()
      ..initialize(chassis.body, backWheel.body, backWheel.body.position, Vector2(0, 1))
      ..enableMotor = true
      ..maxMotorTorque = vehicleType.torque
      ..motorSpeed = 0
      ..dampingRatio = 0.7
      ..frequencyHz = 4.0;
    backJoint = gameRef.world.createJoint(jdBack) as WheelJoint;

    final jdFront = WheelJointDef()
      ..initialize(chassis.body, frontWheel.body, frontWheel.body.position, Vector2(0, 1))
      ..dampingRatio = 0.7
      ..frequencyHz = 4.0;
    frontJoint = gameRef.world.createJoint(jdFront) as WheelJoint;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if flipped
    if (chassis.body.angle.abs() > math.pi / 2 + 0.5) {
      gameRef.gameOver();
    }

    if (gas) {
      backJoint.setMotorSpeed(50);
    } else if (brake) {
      backJoint.setMotorSpeed(-50);
    } else {
      backJoint.setMotorSpeed(0);
    }
  }
}

class Chassis extends BodyComponent<HillClimbGame> {
  final Vector2 _position;
  final VehicleType vehicleType;

  Chassis({required Vector2 position, required this.vehicleType}) : _position = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: _position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBoxXY(2, 0.5); // Adjust dimensions based on car type later if needed

    final fixtureDef = FixtureDef(shape, density: vehicleType.density, friction: 0.5);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = vehicleType.color;
    // Draw a basic car shape
    canvas.drawRect(Rect.fromLTRB(-2, -0.5, 2, 0.5), paint);
    // Draw a small cabin
    canvas.drawRect(Rect.fromLTRB(-1, -1.5, 1, -0.5), paint);
  }
}

class Wheel extends BodyComponent<HillClimbGame> {
  final Vector2 _position;
  final double radius;

  Wheel({required Vector2 position, required this.radius}) : _position = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: _position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape, density: 1.0, friction: 0.9, restitution: 0.1);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset.zero, radius, paint);
    // Draw rims
    final rimPaint = Paint()..color = Colors.grey..strokeWidth = 0.2;
    canvas.drawLine(Offset(-radius, 0), Offset(radius, 0), rimPaint);
    canvas.drawLine(Offset(0, -radius), Offset(0, radius), rimPaint);
  }
}

class Coin extends BodyComponent<HillClimbGame> with ContactCallbacks {
  final Vector2 _position;
  bool collected = false;

  Coin({required Vector2 position}) : _position = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: _position,
      type: BodyType.static,
      isSensor: true,
    );
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = 0.5;
    final fixtureDef = FixtureDef(shape);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    if (collected) return;
    final paint = Paint()..color = AppColors.gold;
    canvas.drawCircle(Offset.zero, 0.5, paint);
    // Draw inner circle
    canvas.drawCircle(Offset.zero, 0.3, Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 0.1);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Chassis || other is Wheel) {
      if (!collected) {
        collected = true;
        gameRef.collectCoin(this);
      }
    }
  }
}

class CoinHud extends PositionComponent with HasGameRef<HillClimbGame> {
  late TextComponent textComponent;

  @override
  Future<void> onLoad() async {
    textComponent = TextComponent(
      text: 'Coins: 0',
      textRenderer: TextPaint(style: const TextStyle(color: AppColors.gold, fontSize: 2)),
    );
    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.viewfinder.position + Vector2(-15, -10);
    textComponent.text = 'Coins: ${gameRef.coinsEarned}';
  }
}