import 'package:flutter/material.dart';
import '../../../../core/models/citizen_services_models.dart';

class InfrastructureReportsWidget extends StatefulWidget {
  const InfrastructureReportsWidget({super.key});

  @override
  State<InfrastructureReportsWidget> createState() => _InfrastructureReportsWidgetState();
}

class _InfrastructureReportsWidgetState extends State<InfrastructureReportsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedLocation = 'Wardha Village, Maharashtra';

  final List<InfrastructureProject> _infrastructureProjects = [
    InfrastructureProject(
      id: '1',
      category: ProjectCategory.water,
      name: 'Village Water Supply System',
      description: 'Installation of bore wells and distribution network for 24x7 water supply',
      status: ProjectStatus.completed,
      progress: 100,
      budget: ProjectBudget(allocated: 1500000, utilized: 1485000),
      timeline: ProjectTimeline(
        startDate: DateTime(2024, 6, 1),
        expectedEndDate: DateTime(2024, 12, 31),
        actualEndDate: DateTime(2024, 12, 20),
      ),
      beneficiaries: 850,
      contractor: 'Maharashtra Water Works Corp',
    ),
    InfrastructureProject(
      id: '2',
      category: ProjectCategory.roads,
      name: 'Village Connecting Road',
      description: '2.5km concrete road connecting village to main highway',
      status: ProjectStatus.completed,
      progress: 100,
      budget: ProjectBudget(allocated: 2500000, utilized: 2450000),
      timeline: ProjectTimeline(
        startDate: DateTime(2024, 8, 1),
        expectedEndDate: DateTime(2025, 1, 31),
        actualEndDate: DateTime(2025, 1, 15),
      ),
      beneficiaries: 1200,
      contractor: 'Roadways Construction Ltd',
    ),
    InfrastructureProject(
      id: '3',
      category: ProjectCategory.sanitation,
      name: 'Community Sanitation Complex',
      description: 'Construction of community toilets and waste management facility',
      status: ProjectStatus.ongoing,
      progress: 75,
      budget: ProjectBudget(allocated: 800000, utilized: 580000),
      timeline: ProjectTimeline(
        startDate: DateTime(2024, 11, 1),
        expectedEndDate: DateTime(2025, 3, 31),
      ),
      beneficiaries: 450,
      contractor: 'Clean India Contractors',
    ),
    InfrastructureProject(
      id: '4',
      category: ProjectCategory.education,
      name: 'Primary School Renovation',
      description: 'Complete renovation of village primary school with smart classrooms',
      status: ProjectStatus.ongoing,
      progress: 60,
      budget: ProjectBudget(allocated: 1200000, utilized: 720000),
      timeline: ProjectTimeline(
        startDate: DateTime(2025, 1, 1),
        expectedEndDate: DateTime(2025, 4, 30),
      ),
      beneficiaries: 180,
      contractor: 'Education Infrastructure Pvt Ltd',
    ),
  ];

  final List<SocialWelfareScheme> _socialWelfareSchemes = [
    SocialWelfareScheme(
      id: '1',
      name: 'PM-AJAY Pension Scheme',
      type: WelfareType.pension,
      beneficiaries: Beneficiaries(target: 120, enrolled: 115, active: 110),
      budget: WelfareBudget(allocated: 1440000, disbursed: 1320000),
      lastUpdate: DateTime(2025, 3, 25),
    ),
    SocialWelfareScheme(
      id: '2',
      name: 'Ayushman Bharat Health Insurance',
      type: WelfareType.healthcare,
      beneficiaries: Beneficiaries(target: 850, enrolled: 780, active: 750),
      budget: WelfareBudget(allocated: 500000, disbursed: 425000),
      lastUpdate: DateTime(2025, 3, 24),
    ),
    SocialWelfareScheme(
      id: '3',
      name: 'PMAY Rural Housing',
      type: WelfareType.housing,
      beneficiaries: Beneficiaries(target: 45, enrolled: 42, active: 38),
      budget: WelfareBudget(allocated: 5400000, disbursed: 4560000),
      lastUpdate: DateTime(2025, 3, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.water:
        return Icons.water_drop;
      case ProjectCategory.roads:
        return Icons.route;
      case ProjectCategory.sanitation:
        return Icons.cleaning_services;
      case ProjectCategory.electricity:
        return Icons.electric_bolt;
      case ProjectCategory.education:
        return Icons.school;
      case ProjectCategory.healthcare:
        return Icons.local_hospital;
    }
  }

  Color _getCategoryColor(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.water:
        return Colors.blue;
      case ProjectCategory.roads:
        return Colors.orange;
      case ProjectCategory.sanitation:
        return Colors.green;
      case ProjectCategory.electricity:
        return Colors.amber;
      case ProjectCategory.education:
        return Colors.purple;
      case ProjectCategory.healthcare:
        return Colors.red;
    }
  }

  Widget _getStatusBadge(ProjectStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ProjectStatus.completed:
        color = Colors.green.shade100;
        text = 'Completed';
        break;
      case ProjectStatus.ongoing:
        color = Colors.blue.shade100;
        text = 'Ongoing';
        break;
      case ProjectStatus.planning:
        color = Colors.amber.shade100;
        text = 'Planning';
        break;
      case ProjectStatus.delayed:
        color = Colors.red.shade100;
        text = 'Delayed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    return '₹${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_city, color: Theme.of(context).primaryColor, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Infrastructure & Development Reports',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track infrastructure development, social welfare schemes, and community initiatives in your area',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLocation,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Card(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Infrastructure Projects'),
                      Tab(text: 'Social Welfare'),
                      Tab(text: 'Educational Initiatives'),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInfrastructureTab(),
                        _buildSocialWelfareTab(),
                        _buildEducationalTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureTab() {
    final totalProjects = _infrastructureProjects.length;
    final completedProjects = _infrastructureProjects.where((p) => p.status == ProjectStatus.completed).length;
    final totalBudget = _infrastructureProjects.fold<int>(0, (sum, p) => sum + p.budget.allocated);
    final totalBeneficiaries = _infrastructureProjects.fold<int>(0, (sum, p) => sum + p.beneficiaries);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                icon: Icons.construction,
                title: 'Total Projects',
                value: totalProjects.toString(),
                color: Colors.blue,
              ),
              _buildSummaryCard(
                icon: Icons.check_circle,
                title: 'Completed',
                value: completedProjects.toString(),
                color: Colors.green,
              ),
              _buildSummaryCard(
                icon: Icons.currency_rupee,
                title: 'Total Budget',
                value: _formatCurrency(totalBudget),
                color: Colors.orange,
              ),
              _buildSummaryCard(
                icon: Icons.people,
                title: 'Beneficiaries',
                value: totalBeneficiaries.toString(),
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Projects List
          ..._infrastructureProjects.map((project) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(project.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(project.category),
                          color: _getCategoryColor(project.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              project.description,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      _getStatusBadge(project.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress, Budget, Timeline
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progress', style: TextStyle(fontSize: 12)),
                                Text('${project.progress}%', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: project.progress / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Budget Utilization', style: TextStyle(fontSize: 12)),
                                Text(
                                  '${((project.budget.utilized / project.budget.allocated) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: project.budget.utilized / project.budget.allocated,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Used: ${_formatCurrency(project.budget.utilized)}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                Text(
                                  'Total: ${_formatCurrency(project.budget.allocated)}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Start Date:', style: TextStyle(fontSize: 11)),
                                Text(
                                  _formatDate(project.timeline.startDate),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Expected End:', style: TextStyle(fontSize: 11)),
                                Text(
                                  _formatDate(project.timeline.expectedEndDate),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            if (project.timeline.actualEndDate != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Completed:', style: TextStyle(fontSize: 11)),
                                  Text(
                                    _formatDate(project.timeline.actualEndDate!),
                                    style: const TextStyle(fontSize: 11, color: Colors.green),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${project.beneficiaries} beneficiaries',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      if (project.contractor != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Contractor: ${project.contractor}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSocialWelfareTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _socialWelfareSchemes.length,
        itemBuilder: (context, index) {
          final scheme = _socialWelfareSchemes[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Last updated: ${_formatDate(scheme.lastUpdate)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Beneficiary Enrollment', style: TextStyle(fontSize: 12)),
                          Text(
                            '${scheme.beneficiaries.enrolled}/${scheme.beneficiaries.target}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: scheme.beneficiaries.enrolled / scheme.beneficiaries.target,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active: ${scheme.beneficiaries.active}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '${((scheme.beneficiaries.enrolled / scheme.beneficiaries.target) * 100).toStringAsFixed(1)}% enrolled',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Budget Disbursement', style: TextStyle(fontSize: 12)),
                          Text(
                            '${_formatCurrency(scheme.budget.disbursed)} / ${_formatCurrency(scheme.budget.allocated)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: scheme.budget.disbursed / scheme.budget.allocated,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scheme.type.toString().split('.').last.replaceAllMapped(
                        RegExp(r'([A-Z])'),
                        (match) => ' ${match.group(0)}',
                      ).trim(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEducationalTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Literacy Program',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Students Enrolled', style: TextStyle(fontSize: 12)),
                      Text('45/60', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 6,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Free computer training for village youth. Program includes basic computer skills, internet usage, and digital payment systems.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adult Literacy Campaign',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Participants', style: TextStyle(fontSize: 12)),
                      Text('28/40', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 6,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Evening literacy classes for adults. Focus on basic reading, writing, and numeracy skills in local language.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}