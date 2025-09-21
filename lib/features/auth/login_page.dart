import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _idCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  Future<void> _emailLogin() async {
    if (_idCtl.text.isEmpty || _pwCtl.text.isEmpty) {
      _msg('아이디/비밀번호를 입력하세요.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // TODO: 실제 로그인 연동
    if (mounted) {
      setState(() => _loading = false);
      context.go('/tabs');
    }
  }

  Future<void> _kakaoLogin() async {
    try {
      setState(() => _loading = true);
      final installed = await isKakaoTalkInstalled();
      if (installed) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }
      if (mounted) context.go('/tabs');
    } catch (e) {
      _msg('카카오 로그인에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFF2EE8A5); // 로그인 버튼 색
    const kakao = Color(0xFFFEE500); // 카카오 버튼 색
    const borderRadius = 16.0;

    InputDecoration inputStyle(String hint) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFBABABA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFF7C7C7C), width: 1.2),
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _loading,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // 상단 타이틀
                    const Text(
                      '면접을 도와주는\n앱이름',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    // 중앙 로고 (assets/logo.png 사용)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 아이디 / 비밀번호 입력
                    TextField(
                      controller: _idCtl,
                      textInputAction: TextInputAction.next,
                      decoration: inputStyle('아이디를 입력하세요'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _pwCtl,
                      obscureText: true,
                      decoration: inputStyle('비밀번호를 입력하세요'),
                    ),
                    const SizedBox(height: 18),

                    // 로그인 버튼 (민트색, 둥근)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _emailLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mint,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            side: const BorderSide(
                                color: Color(0xFF2CBF8E), width: 1),
                          ),
                        ),
                        child: const Text('로그인',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 카카오 로그인 버튼 (노란색, 둥근)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _kakaoLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kakao,
                          foregroundColor: const Color(0xFF191600),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            side: const BorderSide(color: Color(0xFF7C7C7C)),
                          ),
                        ),
                        child: const Text('카카오 로그인',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 하단 회원가입 문구
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: const Text(
                        '아이디가 없으신가요? 회원가입',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // 로딩 인디케이터
      floatingActionButton: _loading
          ? const IgnorePointer(
              child: SizedBox(
                width: 0,
                height: 0,
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          : null,
    );
  }
}
