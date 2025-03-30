import 'package:auth_module/auth_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_module/payment_module.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _UserId(),
            const _LogoutButton(),
            TextButton(
              onPressed:
                  () => Navigator.of(context).push(PaymentScreen.route()),
              child: const Text('Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Logout'),
      onPressed: () {
        context.read<AuthenticationBloc>().add(AuthenticationLogoutPressed());
      },
    );
  }
}

class _UserId extends StatelessWidget {
  const _UserId();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    return Column(
      spacing: 12.0,
      children: [
        Image.network(
          user.photo ?? '',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
        Text(user.email ?? ''),
        Text(user.name ?? ''),
      ],
    );
  }
}
