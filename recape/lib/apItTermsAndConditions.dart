import 'package:flutter/material.dart';

class CapItTermsAndConditions extends StatelessWidget {
  const CapItTermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CapIt Terms and Conditions'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '''
            CapIt Terms and Conditions

            Welcome to CapIt! These terms and conditions (the "Agreement") govern your use of the CapIt app (the "App"). By using the App, you agree to be bound by the terms of this Agreement. If you do not agree to the terms of this Agreement, please do not use the App.

            1. License

            Subject to the terms of this Agreement, we grant you a non-exclusive, non-transferable, royalty-free license to use the App for your personal, non-commercial use. You may not reproduce, distribute, modify, reverse engineer, decompile, or disassemble the App, or create any derivative works of the App.

            2. Acceptable Use

            You agree to use the App in accordance with all applicable laws and regulations. You further agree not to use the App for any of the following purposes:

            * To violate the intellectual property rights of others.
            * To transmit or distribute any material that is harmful, threatening, abusive, hateful, harassing, vulgar, obscene, defamatory, or otherwise objectionable.
            * To interfere with the use and enjoyment of the App by others.
            * To gain unauthorized access to the App or any related systems or networks.

            3. User Content

            You may submit content to the App, including but not limited to text, images, videos, and audio recordings (collectively, "User Content"). By submitting User Content to the App, you grant us a non-exclusive, transferable, royalty-free license to use, reproduce, distribute, modify, display, and publicly perform your User Content in connection with the App. You also agree that your User Content will not violate the intellectual property rights of others or any applicable laws and regulations.

            4. Warranties and Disclaimers

            THE APP AND USER CONTENT ARE PROVIDED "AS IS" AND WITHOUT ANY WARRANTIES, EXPRESS OR IMPLIED. WE DISCLAIM ALL WARRANTIES, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

            5. Limitation of Liability

            TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE APP OR USER CONTENT, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

            6. Governing Law

            This Agreement shall be governed by and construed in accordance with the laws of the State of [State Name].

            7. Entire Agreement

            This Agreement constitutes the entire agreement between you and us with respect to the App and supersedes all prior or contemporaneous communications and agreements, whether oral or written.

            8. Severability

            If any provision of this Agreement is held to be invalid or unenforceable, such provision shall be struck from this Agreement and the remaining provisions shall remain in full force and effect.

            9. Changes to This Agreement

            We reserve the right to modify this Agreement at any time. Any changes to this Agreement will be posted on the App and will take effect immediately upon posting. Your continued use of the App following any changes to this Agreement constitutes your acceptance of such changes.

            10. Contact Us

            If you have any questions about this Agreement, please contact us at [savefor4ever@gmail.com]
            ''',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
