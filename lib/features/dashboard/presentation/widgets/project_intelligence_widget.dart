import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_intelligence_models.dart';
import '../../data/mock_project_intelligence_data.dart';

class ProjectIntelligenceWidget extends ConsumerStatefulWidget {
  const ProjectIntelligenceWidget({super.key});

  @override
  ConsumerState<ProjectIntelligenceWidget> createState() => _ProjectIntelligenceWidgetState();
}

class _ProjectIntelligenceWidgetState extends ConsumerState<ProjectIntelligenceWidget> {
  String _selectedTab = 'scorecard';
  final String _selectedProjectId = 'PRJ001';
  late ProjectIntelligence _intelligence;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _intelligence = MockProjectIntelligenceData.generateMockProjectIntelligence(_selectedProjectId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildOverallHealthBanner(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, size: 32, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '360° Project Intelligence',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Comprehensive Multi-Dimensional Project Analysis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildProjectSelector(),
      ],
    );
  }

  Widget _buildProjectSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.folder, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            _intelligence.scorecard.projectName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildOverallHealthBanner() {
    final scorecard = _intelligence.scorecard;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scorecard.overallHealth.color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scorecard.overallHealth.color),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: scorecard.overallHealth.color,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  scorecard.overallScore.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(scorecard.overallHealth.icon, color: scorecard.overallHealth.color),
                    const SizedBox(width: 8),
                    Text(
                      'Overall Health: ${scorecard.overallHealth.label}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickStat('Budget', '${(scorecard.budgetUtilization * 100).toStringAsFixed(0)}%', Icons.attach_money),
                    _buildQuickStat('Schedule', '${scorecard.scheduleVariance.toStringAsFixed(0)}d', Icons.schedule),
                    _buildQuickStat('Issues', scorecard.qualityIssues.toString(), Icons.warning),
                    _buildQuickStat('Risks', scorecard.openRisks.toString(), Icons.flag),
                    _buildQuickStat('Stakeholders', scorecard.stakeholderCount.toString(), Icons.people),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTab('scorecard', 'Scorecard', Icons.dashboard),
        _buildTab('stakeholders', 'Stakeholders', Icons.people),
        _buildTab('health', 'Health', Icons.monitor_heart),
        _buildTab('predictive', 'Predictive', Icons.trending_up),
        _buildTab('kpis', 'KPIs', Icons.insights),
      ],
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final isSelected = _selectedTab == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Colors.blue[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedTab = id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'stakeholders':
        return _buildStakeholdersView();
      case 'health':
        return _buildHealthView();
      case 'predictive':
        return _buildPredictiveView();
      case 'kpis':
        return _buildKPIsView();
      default:
        return _buildScorecardView();
    }
  }

  Widget _buildScorecardView() {
    final scorecard = _intelligence.scorecard;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDimensionScores(scorecard),
          const SizedBox(height: 24),
          _buildTrendAnalysis(scorecard),
        ],
      ),
    );
  }

  Widget _buildDimensionScores(ProjectScorecard scorecard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Multi-Dimensional Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          _buildDimensionBar('Financial Health', scorecard.financialHealth, Colors.green, scorecard.financialTrend),
          _buildDimensionBar('Timeline Adherence', scorecard.timelineAdherence, Colors.blue, scorecard.timelineTrend),
          _buildDimensionBar('Quality Compliance', scorecard.qualityCompliance, Colors.purple, scorecard.qualityTrend),
          _buildDimensionBar('Stakeholder Satisfaction', scorecard.stakeholderSatisfaction, Colors.orange, 0),
          _buildDimensionBar('Risk Management', scorecard.riskManagement, Colors.red, 0),
          _buildDimensionBar('Resource Utilization', scorecard.resourceUtilization, Colors.teal, 0),
        ],
      ),
    );
  }

  Widget _buildDimensionBar(String label, double value, Color color, double trend) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Row(
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (trend != 0) ...[
                    const SizedBox(width: 8),
                    Icon(
                      trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: trend > 0 ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${trend.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: trend > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(ProjectScorecard scorecard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard('Financial', scorecard.financialTrend, Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTrendCard('Timeline', scorecard.timelineTrend, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTrendCard('Quality', scorecard.qualityTrend, Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String label, double trend, Color color) {
    final isPositive = trend > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                '${trend.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStakeholdersView() {
    return Column(
      children: [
        _buildStakeholderNetwork(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildStakeholderList(),
        ),
      ],
    );
  }

  Widget _buildStakeholderNetwork() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Stakeholder Network Map',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '${_intelligence.stakeholders.length} stakeholders mapped',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStakeholderList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _intelligence.stakeholders.length,
        itemBuilder: (context, index) => _buildStakeholderCard(_intelligence.stakeholders[index]),
      ),
    );
  }

  Widget _buildStakeholderCard(Stakeholder stakeholder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: stakeholder.type.color,
              child: Text(
                stakeholder.name.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stakeholder.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${stakeholder.role} • ${stakeholder.organization}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfluenceIndicator('Influence', stakeholder.influenceScore),
                      const SizedBox(width: 16),
                      _buildInfluenceIndicator('Engagement', stakeholder.engagementLevel),
                    ],
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(stakeholder.type.label, style: const TextStyle(fontSize: 10)),
              backgroundColor: stakeholder.type.color,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfluenceIndicator(String label, double value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        ...List.generate(
          5,
          (i) => Icon(
            Icons.circle,
            size: 8,
            color: i < (value * 5) ? Colors.orange : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthView() {
    final metrics = _intelligence.healthMetrics;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRealTimeIndicators(metrics),
          const SizedBox(height: 16),
          _buildPredictiveIndicators(metrics),
          const SizedBox(height: 16),
          _buildRecentActivities(metrics),
        ],
      ),
    );
  }

  Widget _buildRealTimeIndicators(ProjectHealthMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-Time Health Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Cash Flow Rate', '₹${(metrics.cashFlowRate / 1000).toStringAsFixed(0)}K/day', Icons.attach_money, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard('Completion Velocity', '${metrics.completionVelocity.toStringAsFixed(1)}%/week', Icons.speed, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard('Active Issues', metrics.activeIssues.toString(), Icons.warning, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard('Critical Alerts', metrics.criticalAlerts.toString(), Icons.error, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveIndicators(ProjectHealthMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predictive Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completion Probability', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: metrics.completionProbability,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        metrics.completionProbability > 0.8 ? Colors.green : Colors.orange,
                      ),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(metrics.completionProbability * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Predicted Completion', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(metrics.predictedCompletion!),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Overrun Risk', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      '${(metrics.budgetOverrunRisk * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: metrics.budgetOverrunRisk > 0.3 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(ProjectHealthMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActivityCount('Transactions', metrics.recentTransactions, Icons.payment),
              _buildActivityCount('Inspections', metrics.recentInspections, Icons.search),
              _buildActivityCount('Approvals', metrics.recentApprovals, Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCount(String label, int count, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue[700], size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictiveView() {
    final analytics = _intelligence.predictiveAnalytics;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCompletionForecast(analytics),
          const SizedBox(height: 16),
          _buildRiskAnalysis(analytics),
          const SizedBox(height: 16),
          _buildRecommendations(analytics),
        ],
      ),
    );
  }

  Widget _buildCompletionForecast(PredictiveAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Completion', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(analytics.estimatedCompletion),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Confidence Level', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      '${(analytics.confidenceLevel * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: analytics.confidenceLevel > 0.8 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projected Final Cost', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      '₹${(analytics.projectedFinalCost / 10000000).toStringAsFixed(1)}Cr',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysis(PredictiveAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          ...analytics.delayRisks.map((risk) => _buildRiskCard(
            risk.factor,
            '${risk.impactDays.toStringAsFixed(0)} days delay',
            risk.probability,
            risk.mitigation,
            Colors.orange,
          )),
          ...analytics.costRisks.map((risk) => _buildRiskCard(
            risk.factor,
            '₹${(risk.impactAmount / 100000).toStringAsFixed(1)}L overrun',
            risk.probability,
            risk.mitigation,
            Colors.red,
          )),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String factor, String impact, double probability, String mitigation, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    factor,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(probability * 100).toStringAsFixed(0)}% probability',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Impact: $impact', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text('Mitigation: $mitigation', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(PredictiveAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actionable Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          ...analytics.recommendations.map((insight) => _buildRecommendationCard(insight)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(ActionableInsight insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: insight.priority.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    insight.priority.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(insight.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 8),
            ...insight.actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(action)),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Potential Impact: ${(insight.potentialImpact * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildKPIsView() {
    final kpis = _intelligence.keyPerformanceIndicators;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Performance Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: kpis.entries.map((entry) => _buildKPICard(entry.key, entry.value)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, double value) {
    final color = value >= 0.9 ? Colors.green : (value >= 0.7 ? Colors.orange : Colors.red);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}