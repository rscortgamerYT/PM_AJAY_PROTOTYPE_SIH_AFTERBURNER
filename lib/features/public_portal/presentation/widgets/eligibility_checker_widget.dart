import 'package:flutter/material.dart';
import '../../../../core/models/citizen_services_models.dart';

class EligibilityCheckerWidget extends StatefulWidget {
  const EligibilityCheckerWidget({super.key});

  @override
  State<EligibilityCheckerWidget> createState() => _EligibilityCheckerWidgetState();
}

class _EligibilityCheckerWidgetState extends State<EligibilityCheckerWidget> {
  final _formKey = GlobalKey<FormState>();
  
  String _category = '';
  int _annualIncome = 0;
  int _age = 0;
  String _educationLevel = '';

  List<EligibilityCriteria> _eligibilityResults = [];
  bool _isChecking = false;
  bool _hasChecked = false;

  final List<EligibilityCriteria> _pmAjaySchemes = [
    EligibilityCriteria(
      id: 'adarsh-gram-scholarship',
      name: 'Adarsh Gram Education Scholarship',
      description: 'Educational support for SC students in Adarsh Gram villages',
      benefits: [
        '₹5,000 annually for school students',
        'Free textbooks and uniforms',
        'Merit-based additional grants'
      ],
      requirements: EligibilityRequirements(
        category: 'SC',
        annualIncome: 300000,
        age: AgeRange(min: 6, max: 18),
        location: 'Adarsh Gram designated villages',
        educationLevel: 'School',
      ),
    ),
    EligibilityCriteria(
      id: 'hostel-accommodation',
      name: 'PM-AJAY Hostel Accommodation',
      description: 'Free hostel facility for SC students near educational institutions',
      benefits: [
        'Free accommodation',
        'Mess facility',
        'Study materials'
      ],
      requirements: EligibilityRequirements(
        category: 'SC',
        annualIncome: 250000,
        age: AgeRange(min: 16, max: 25),
        location: 'Near colleges/universities',
        educationLevel: 'Higher Secondary or above',
      ),
    ),
    EligibilityCriteria(
      id: 'gia-skill-training',
      name: 'GIA Skill Development Program',
      description: 'Vocational training and skill development for SC youth',
      benefits: [
        'Free training',
        'Stipend during training',
        'Job placement assistance',
        'Tool kit'
      ],
      requirements: EligibilityRequirements(
        category: 'SC',
        annualIncome: 400000,
        age: AgeRange(min: 18, max: 35),
        location: 'Any',
        educationLevel: 'Minimum 8th pass',
      ),
    ),
    EligibilityCriteria(
      id: 'entrepreneurship-grant',
      name: 'SC Entrepreneurship Support Grant',
      description: 'Financial assistance for starting small businesses',
      benefits: [
        'Up to ₹2,00,000 grant',
        'Business mentorship',
        'Market linkage support'
      ],
      requirements: EligibilityRequirements(
        category: 'SC',
        annualIncome: 500000,
        age: AgeRange(min: 21, max: 45),
        location: 'Any',
        educationLevel: 'Minimum 10th pass',
      ),
    ),
  ];

  Future<void> _checkEligibility() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isChecking = true;
      _hasChecked = false;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final eligible = _pmAjaySchemes.where((scheme) {
      final req = scheme.requirements;

      // Check category
      if (req.category != _category) return false;

      // Check income
      if (_annualIncome > req.annualIncome) return false;

      // Check age if specified
      if (req.age != null && (_age < req.age!.min || _age > req.age!.max)) return false;

      return true;
    }).toList();

    setState(() {
      _eligibilityResults = eligible;
      _isChecking = false;
      _hasChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PM-AJAY Benefits Eligibility Checker',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enter your details to discover PM-AJAY schemes and benefits you\'re eligible for',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _category.isEmpty ? null : _category,
                    items: const [
                      DropdownMenuItem(value: 'SC', child: Text('Scheduled Caste (SC)')),
                      DropdownMenuItem(value: 'ST', child: Text('Scheduled Tribe (ST)')),
                      DropdownMenuItem(value: 'OBC', child: Text('Other Backward Classes (OBC)')),
                      DropdownMenuItem(value: 'General', child: Text('General')),
                    ],
                    onChanged: (value) => setState(() => _category = value ?? ''),
                    validator: (value) => value == null ? 'Please select category' : null,
                  ),
                  const SizedBox(height: 16),
                  // Annual Income
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Annual Family Income (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _annualIncome = int.tryParse(value) ?? 0,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter income';
                      if (int.tryParse(value) == null) return 'Please enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _age = int.tryParse(value) ?? 0,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (int.tryParse(value) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'PIN Code',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (value.length != 6) return 'Invalid PIN';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Education Level',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _educationLevel.isEmpty ? null : _educationLevel,
                          items: const [
                            DropdownMenuItem(value: 'Below 8th', child: Text('Below 8th')),
                            DropdownMenuItem(value: '8th pass', child: Text('8th Pass')),
                            DropdownMenuItem(value: '10th pass', child: Text('10th Pass')),
                            DropdownMenuItem(value: '12th pass', child: Text('12th Pass')),
                            DropdownMenuItem(value: 'Graduate', child: Text('Graduate')),
                            DropdownMenuItem(value: 'Post Graduate', child: Text('Post Graduate')),
                          ],
                          onChanged: (value) => setState(() => _educationLevel = value ?? ''),
                          validator: (value) => value == null ? 'Please select' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Family Size',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (int.tryParse(value) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkEligibility,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isChecking
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Checking Eligibility...'),
                              ],
                            )
                          : const Text('Check My Eligibility'),
                    ),
                  ),
                ],
              ),
            ),
            if (_hasChecked) ...[
              const SizedBox(height: 32),
              if (_eligibilityResults.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are eligible for ${_eligibilityResults.length} scheme(s)!',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._eligibilityResults.map((scheme) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.name,
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scheme.description,
                          style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Benefits:',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...scheme.benefits.map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, 
                                color: Colors.green.shade700, 
                                size: 16
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to application form
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          child: const Text('Apply Now'),
                        ),
                      ],
                    ),
                  ),
                )),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Direct Eligibility Found',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You may still be eligible for other government schemes. Contact your local office for more information.',
                              style: TextStyle(color: Colors.amber.shade800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}