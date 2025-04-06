import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 234, 30, 73),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('GKH監測小站'),
            _buildGradientButton('Sign up', 'assets/vectors/vector_4_x2.svg',
                Color(0xFF4960F9), Color(0xFF1433FF)),
            _buildGradientButton(
                'Sign In', null, Color(0xFF4960F9), Color(0xFFCF85E8)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 283),
        child: Text(
          title,
          style: GoogleFonts.abel(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            fontSize: 48,
            height: 0.7,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, String? svgPath, Color startColor, Color endColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 44),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment(-1, -1.583),
            end: Alignment(1, 1.5),
            colors: [startColor, endColor],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment(-1, -1.583),
                    end: Alignment(1, 1.5),
                    colors: [startColor, endColor],
                  ),
                ),
              ),
            ),
            Padding(
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
                  if (svgPath != null)
                    SizedBox(
                      width: 19,
                      height: 15,
                      child: SvgPicture.asset(svgPath),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
