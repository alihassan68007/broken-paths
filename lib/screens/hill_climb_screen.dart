import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class HillClimbScreen extends StatelessWidget {
  const HillClimbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: AppConstants.aspectRatio,
          child: GameWidget(
            game: HillClimbGame(
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
}

class HillClimbGame extends Forge2DGame with HasKeyboardHandlerComponents {
  final Function(int) onGameEnd;
  late Car car;
  int coinsEarned = 0;
  bool isGameOver = false;

  HillClimbGame({required this.onGameEnd}) : super(zoom: 10, gravity: Vector2(0, 9.8));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Camera setup
    camera.viewport = FixedAspectRatioViewport(aspectRatio: AppConstants.aspectRatio);

    // Add terrain
    await add(Terrain());

    // Add car
    car = Car(position: Vector2(10, -10));
    await add(car);

    // Follow car
    camera.follow(car.chassis);

    // Add coins
    for (int i = 0; i < 20; i++) {
      await add(Coin(position: Vector2(20.0 + i * 15.0, -15)));
    }

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

    // UI Text for Coins
    add(CoinHud());
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

class Terrain extends BodyComponent<HillClimbGame> {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.static,
    );
    final body = world.createBody(bodyDef);

    final shape = ChainShape();
    final List<Vector2> vertices = [];
    for (double x = -10; x < 500; x += 5) {
      double y = math.sin(x / 10) * 5 + math.cos(x / 20) * 3;
      vertices.add(Vector2(x, y));
    }
    shape.createChain(vertices);

    final fixtureDef = FixtureDef(shape, friction: 0.8, restitution: 0.1);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // Basic terrain rendering
    final paint = Paint()..color = Colors.brown..strokeWidth = 0.5..style = PaintingStyle.stroke;
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

class Car extends Component with HasGameRef<HillClimbGame> {
  final Vector2 position;
  late BodyComponent chassis;
  late Wheel backWheel;
  late Wheel frontWheel;
  late WheelJoint backJoint;
  late WheelJoint frontJoint;

  bool gas = false;
  bool brake = false;

  Car({required this.position});

  @override
  Future<void> onLoad() async {
    chassis = Chassis(position: position);
    await gameRef.add(chassis);

    backWheel = Wheel(position: position + Vector2(-1.5, 1));
    await gameRef.add(backWheel);

    frontWheel = Wheel(position: position + Vector2(1.5, 1));
    await gameRef.add(frontWheel);

    final jdBack = WheelJointDef()
      ..initialize(chassis.body, backWheel.body, backWheel.body.position, Vector2(0, 1))
      ..enableMotor = true
      ..maxMotorTorque = 1000
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

  Chassis({required Vector2 position}) : _position = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: _position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBoxXY(2, 0.5);

    final fixtureDef = FixtureDef(shape, density: 1.0, friction: 0.5);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTRB(-2, -0.5, 2, 0.5), paint);
  }
}

class Wheel extends BodyComponent<HillClimbGame> {
  final Vector2 _position;

  Wheel({required Vector2 position}) : _position = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: _position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = 0.8;
    final fixtureDef = FixtureDef(shape, density: 1.0, friction: 0.9, restitution: 0.1);
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset.zero, 0.8, paint);
    // Draw spoke to see rotation
    canvas.drawLine(Offset.zero, const Offset(0.8, 0), Paint()..color = Colors.white..strokeWidth=0.1);
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
    // Fixed to camera
    position = Vector2(gameRef.camera.viewport.virtualWidth / 2 - 20, 5); // Approximate placement
  }

  @override
  void update(double dt) {
    super.update(dt);
    // For Forge2D games without a separate HUD camera layer, simple text positioning:
    position = gameRef.camera.viewfinder.position + Vector2(-15, -10);
    textComponent.text = 'Coins: ${gameRef.coinsEarned}';
  }
}
