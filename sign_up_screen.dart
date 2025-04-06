import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.05,
          screenHeight * 0.05,
          screenWidth * 0.05,
          screenHeight * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(screenWidth),
            _buildTitle(),
            _buildInputField(
                'Email Address', '3b117161@gm.student.ncut.edu.tw'),
            _buildInputField('Password', '3B117161'),
            _buildForgotPasswordText(),
            _buildGradientButton('Sign up', 'assets/vectors/vector_8_x2.svg',
                Color(0xFF4960F9), Color(0xFF1433FF)),
            _buildGradientButton('Sign In', 'assets/vectors/vector_10_x2.svg',
                Color(0xFF4960F9), Color(0xFFCF85E8)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: SvgPicture.asset(
              'assets/vectors/vector_14_x2.svg',
            ),
          ),
          Text(
            'Sign Up',
            style: GoogleFonts.abel(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 33),
      child: Text(
        'Sign Up',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 9),
            child: Text(
              label,
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 7),
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 148),
      child: Text(
        'Forgot Password?',
        style: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.w400,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, String svgPath, Color startColor, Color endColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment(-1, -1.583),
            end: Alignment(1, 1.5),
            colors: [startColor, endColor],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 24, 24.4, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 19,
                height: 15,
                child: SvgPicture.asset(
                  svgPath,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
