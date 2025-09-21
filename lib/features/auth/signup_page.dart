import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtl = TextEditingController();
  final _birthCtl = TextEditingController(); // YYYY
  final _emailCtl = TextEditingController(); // 아이디(이메일 권장)
  final _pwCtl = TextEditingController();
  final _nickCtl = TextEditingController();

  bool _loading = false;
  bool? _emailOk; // true=사용가능, false=중복, null=미확인
  bool? _nickOk;

  @override
  void dispose() {
    _nameCtl.dispose();
    _birthCtl.dispose();
    _emailCtl.dispose();
    _pwCtl.dispose();
    _nickCtl.dispose();
    super.dispose();
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFBABABA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7C7C7C), width: 1.2),
        ),
      );

  Future<void> _checkEmailDup() async {
    final email = _emailCtl.text.trim().toLowerCase();
    if (email.isEmpty) return _msg('아이디(이메일)를 입력하세요.');
    setState(() => _loading = true);
    try {
      // usernames 컬렉션에 이메일을 문서 ID로 예약(조회만)
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(email)
          .get();
      setState(() => _emailOk = !doc.exists);
      _msg(doc.exists ? '이미 사용 중인 아이디예요.' : '사용 가능한 아이디예요.');
    } catch (e) {
      _msg('아이디 확인 중 오류가 발생했어요.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkNickDup() async {
    final nickname = _nickCtl.text.trim();
    if (nickname.isEmpty) return _msg('닉네임을 입력하세요.');
    setState(() => _loading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('nicknames')
          .doc(nickname)
          .get();
      setState(() => _nickOk = !doc.exists);
      _msg(doc.exists ? '이미 사용 중인 닉네임이에요.' : '사용 가능한 닉네임이에요.');
    } catch (e) {
      _msg('닉네임 확인 중 오류가 발생했어요.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    final name = _nameCtl.text.trim();
    final birth = _birthCtl.text.trim();
    final email = _emailCtl.text.trim().toLowerCase();
    final pw = _pwCtl.text;
    final nickname = _nickCtl.text.trim();

    if ([name, birth, email, pw, nickname].any((v) => v.isEmpty)) {
      return _msg('모든 항목을 입력하세요.');
    }
    if (birth.length != 4 || int.tryParse(birth) == null) {
      return _msg('출생년도를 YYYY 형식으로 입력하세요.');
    }
    if (_emailOk == false || _nickOk == false) {
      return _msg('아이디/닉네임 중복을 확인해주세요.');
    }

    setState(() => _loading = true);
    try {
      // 1) Firebase Auth 사용자 생성 (이메일/비번)
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pw);

      final uid = cred.user!.uid;
      final db = FirebaseFirestore.instance;

      // 2) (MVP 방식) usernames / nicknames 문서 예약 → 중복 방지
      //   ※ 경쟁 조건을 완벽히 막으려면 Cloud Functions에서 트랜잭션으로 처리 권장
      await db.runTransaction((tx) async {
        final uRef = db.collection('usernames').doc(email);
        final nRef = db.collection('nicknames').doc(nickname);
        if ((await tx.get(uRef)).exists) {
          throw Exception('아이디가 이미 예약되었습니다.');
        }
        if ((await tx.get(nRef)).exists) {
          throw Exception('닉네임이 이미 예약되었습니다.');
        }
        tx.set(uRef, {'uid': uid, 'at': FieldValue.serverTimestamp()});
        tx.set(nRef, {'uid': uid, 'at': FieldValue.serverTimestamp()});
      });

      // 3) users/{uid} 프로필 저장
      await db.collection('users').doc(uid).set({
        'name': name,
        'birthYear': int.parse(birth),
        'email': email,
        'nickname': nickname,
        'resumePublic': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _msg('회원가입이 완료되었습니다.');
      if (mounted) context.go('/'); // 완료 후 로그인 화면으로
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? '회원가입 실패');
    } catch (e) {
      _msg('회원가입 중 오류가 발생했어요.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFF2EE8A5);
    const kakao = Color(0xFFFEE500); // 사용은 안 하지만 통일성 위해
    const r = 16.0;

    Widget rowWithCheck({
      required TextEditingController controller,
      required String hint,
      required VoidCallback onCheck,
      bool? ok,
      TextInputType? keyboardType,
      bool obscure = false,
    }) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              decoration: _input(hint).copyWith(
                suffixIcon: ok == null
                    ? null
                    : Icon(ok ? Icons.check_circle : Icons.error,
                        color: ok ? Colors.green : Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onCheck,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r),
                ),
              ),
              child: const Text('중복확인'),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _loading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  TextField(controller: _nameCtl, decoration: _input('이름')),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _birthCtl,
                    keyboardType: TextInputType.number,
                    decoration: _input('출생년도 (YYYY)'),
                  ),
                  const SizedBox(height: 14),
                  // 아이디(이메일) + 중복확인
                  rowWithCheck(
                    controller: _emailCtl,
                    hint: '아이디 (이메일 형식 권장)',
                    keyboardType: TextInputType.emailAddress,
                    onCheck: _checkEmailDup,
                    ok: _emailOk,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pwCtl,
                    obscureText: true,
                    decoration: _input('비밀번호'),
                  ),
                  const SizedBox(height: 14),
                  // 닉네임 + 중복확인
                  rowWithCheck(
                    controller: _nickCtl,
                    hint: '닉네임',
                    onCheck: _checkNickDup,
                    ok: _nickOk,
                  ),
                  const SizedBox(height: 24),

                  // 가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mint,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r),
                          side: const BorderSide(
                              color: Color(0xFF2CBF8E), width: 1),
                        ),
                      ),
                      child: const Text('회원가입',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('이미 계정이 있으신가요? 로그인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          _loading ? const Center(child: CircularProgressIndicator()) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
