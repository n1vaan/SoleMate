import 'package:flutter/material.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';


class SupportPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
         leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined), onPressed: (){
          Navigator.pop(context);
         },),
        title: const Text('          Support'),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _messageController,
                  labelText: 'Message',
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                GradientButton(text: "Submit", onPressed: (){}),



                const SizedBox(height: 40),
                const Text(
                  "FAQs",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const FAQItem(
                  question: 'How can I reset my password?',
                  answer:
                      'You can reset your password by going to the Change Password page and following the instructions.',
                ),
                const FAQItem(
                  question: 'How do I contact support?',
                  answer:
                      'You can contact support by filling out the contact form on this page or sending an email to support@example.com.',
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int maxLines;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          
        
        ),
        
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
