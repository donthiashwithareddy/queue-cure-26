import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Queue Cure '26",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
      ),
      home: const MainLayoutShell(),
    );
  }
}

class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  // Navigation Track State & Sidebar Drawer Toggle State
  String currentTab = 'Dashboard';
  bool isSidebarOpen = true; 

  // Queue Data Store Running in App Memory
  final List<Map<String, dynamic>> patientQueue = [];
  int tokenCounter = 1;
  int totalServedToday = 0;
  int avgConsultancyTime = 12;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeController.text = avgConsultancyTime.toString();
  }

  // Functional Execution Controllers
  void addPatient() {
    final String enteredName = nameController.text.trim();
    if (enteredName.isNotEmpty) {
      final int allocatedTime = int.tryParse(timeController.text.trim()) ?? avgConsultancyTime;
      
      setState(() {
        patientQueue.add({
          'token': tokenCounter,
          'name': enteredName,
          'expectedTime': allocatedTime,
        });
        tokenCounter++;
      });
      nameController.clear();
    }
  }

  void callNextToken() {
    if (patientQueue.isNotEmpty) {
      setState(() {
        patientQueue.removeAt(0);
        totalServedToday++;
      });
    }
  }

  void flushQueueData() {
    setState(() {
      patientQueue.clear();
      totalServedToday = 0;
      tokenCounter = 1;
    });
  }

  // Dynamic Parameter Recalculations
  int calculateTotalWaitTime() {
    if (patientQueue.length <= 1) return 0;
    int waitTime = 0;
    for (int i = 0; i < patientQueue.length - 1; i++) {
      waitTime += (patientQueue[i]['expectedTime'] as int);
    }
    return waitTime;
  }

  @override
  void dispose() {
    nameController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800; // Auto-detects device layout type

    // Universal sidebar builder logic used for both laptops and sliding drawers
    Widget buildSidebarContent() {
      return Container(
        width: 240,
        color: const Color(0xFF090D16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Queue Cure '26",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                // Toggle Close button visible inside layout menu rail
                IconButton(
                  icon: const Icon(Icons.menu_open_rounded, color: Colors.grey),
                  onPressed: () {
                    if (isMobile) {
                      Navigator.pop(context); // Native phone overlay collapse
                    } else {
                      setState(() => isSidebarOpen = false); // Desktop layout close tracking
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSidebarItem(Icons.grid_view_rounded, 'Dashboard', isMobile),
            const SizedBox(height: 12),
            _buildSidebarItem(Icons.people_alt_rounded, 'Patients', isMobile),
            const SizedBox(height: 12),
            _buildSidebarItem(Icons.settings_rounded, 'Settings', isMobile),
          ],
        ),
      );
    }

    return Scaffold(
      // Native Drawer overlay component used automatically on phone screens
      drawer: isMobile ? Drawer(child: buildSidebarContent()) : null,
      body: Row(
        children: [
          // 1. LAPTOP SIDEBAR: Hidden completely if on mobile or manually collapsed
          if (!isMobile && isSidebarOpen) buildSidebarContent(),

          // 2. MAIN CORE VIEWS CONTROLLER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Global responsive Header Strip Layout Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      // Trigger Button: Shows Hamburger menu button on phones, or Open tab icon on laptops
                      if (isMobile)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        )
                      else if (!isSidebarOpen)
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                          onPressed: () => setState(() => isSidebarOpen = true),
                        ),
                      SizedBox(width: (isMobile || !isSidebarOpen) ? 12 : 8),
                      Text(
                        currentTab,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Active Layout Router Workspace Canvas
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: _buildActiveView(isMobile),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isMobile) {
    final bool isSelected = currentTab == title;
    return InkWell(
      onTap: () {
        setState(() => currentTab = title);
        if (isMobile) Navigator.pop(context); // Closes drawer path overlay on phone taps
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey, size: 20),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView(bool isMobile) {
    switch (currentTab) {
      case 'Patients':
        return _buildPatientsView();
      case 'Settings':
        return _buildSettingsView();
      case 'Dashboard':
      default:
        return _buildDashboardView(isMobile);
    }
  }

  // ==========================================
  // VIEW A: RESPONSIVE DASHBOARD MONITOR VIEWS
  // ==========================================
  Widget _buildDashboardView(bool isMobile) {
    final String currentServing = patientQueue.isNotEmpty ? patientQueue[0]['name'] : 'NONE';
    final String upNext = patientQueue.length > 1 ? patientQueue[1]['name'] : 'NONE ACTIVE';
    final int estTotalWaitTime = calculateTotalWaitTime();

    // Responsive element configuration for metric rows
    Widget metricsRow = Row(
      children: [
        Expanded(child: _buildMetricCard(Icons.timer_outlined, 'Avg Consultancy', '$avgConsultancyTime Mins', Colors.tealAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(Icons.hourglass_empty_rounded, 'Total Wait', '$estTotalWaitTime Mins', Colors.greenAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(Icons.check_circle_outline_rounded, 'Served Today', '$totalServedToday', Colors.lightBlueAccent)),
      ],
    );

    Widget metricsColumn = Column(
      children: [
        _buildMetricCard(Icons.timer_outlined, 'Avg Consultancy Time', '$avgConsultancyTime Mins', Colors.tealAccent),
        const SizedBox(height: 12),
        _buildMetricCard(Icons.hourglass_empty_rounded, 'Est. Total Wait Time', '$estTotalWaitTime Mins', Colors.greenAccent),
        const SizedBox(height: 12),
        _buildMetricCard(Icons.check_circle_outline_rounded, 'Total Served Today', '$totalServedToday Patients', Colors.lightBlueAccent),
      ],
    );

    // Control desk layouts config layout splits
    Widget mainContentLayout = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildAddPatientCard(),
              const SizedBox(height: 24),
              _buildConsoleControlCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildNowServingCard(currentServing, upNext, 385),
        )
      ],
    );

    Widget mobileContentLayout = Column(
      children: [
        _buildNowServingCard(currentServing, upNext, 240),
        const SizedBox(height: 20),
        _buildAddPatientCard(),
        const SizedBox(height: 20),
        _buildConsoleControlCard(),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile ? metricsColumn : metricsRow,
        const SizedBox(height: 24),
        isMobile ? mobileContentLayout : mainContentLayout,
      ],
    );
  }

  Widget _buildAddPatientCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Patient to System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter full patient name',
              fillColor: const Color(0xFF0F172A),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: timeController,
            decoration: InputDecoration(
              suffixText: 'mins',
              suffixStyle: const TextStyle(color: Colors.grey),
              fillColor: const Color(0xFF0F172A),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: addPatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Patient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConsoleControlCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Queue Control Console', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: patientQueue.isEmpty ? null : callNextToken,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: patientQueue.isEmpty ? Colors.grey.shade800 : const Color(0xFF10B981)),
                foregroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Call Next Token', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNowServingCard(String currentServing, String upNext, double targetHeight) {
    return Container(
      height: targetHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('NOW SERVING', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(
            currentServing.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: currentServing == 'NONE' ? 44 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF24324D)),
          const SizedBox(height: 16),
          const Text('UP NEXT', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(
            upNext.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // VIEW B: ACTIVE WAITING REGISTRY REGISTER
  // ==========================================
  Widget _buildPatientsView() {
    final int totalDelay = calculateTotalWaitTime();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Waiting Registry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Total Patients Waiting: ${patientQueue.length}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                child: Text('Est. Delay: $totalDelay mins', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 32),
          patientQueue.isEmpty
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No Active Patients in Queue', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patientQueue.length,
                  itemBuilder: (context, index) {
                    final patient = patientQueue[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF1E293B),
                                child: Text('${patient['token']}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Text(patient['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('${patient['expectedTime']} mins allotted', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                )
        ],
      ),
    );
  }

  // ==========================================
  // VIEW C: BENCH COMPLIANCE & RULES PARAMETERS
  // ==========================================
  Widget _buildSettingsView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24324D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submission & Compliance Architecture Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('System parameters required to pass internal project validation.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),
          _buildComplianceRule('Rule 1: Sequential Allocation', 'Tokens must follow continuous natural sequencing strictly starting from 1 with zero drops.'),
          _buildComplianceRule('Rule 2: Dynamic Wait Mapping', 'Waiting registry metrics must auto-recalculate estimations dynamically using current array states.'),
          _buildComplianceRule('Rule 3: Non-Persistent Cache Flushing', 'Hard resets must drop entire socket buffer memory stacks cleanly without leaking states.'),
          _buildComplianceRule('Rule 4: State Preservation', 'Real-time navigation switching across the sidebar rail must preserve active web pipelines seamlessly.'),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF24324D)),
          const SizedBox(height: 24),
          const Text('Operational Bench Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flush Queue History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Flushes active server arrays instantly across all nodes', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: flushQueueData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Flush Queue', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildComplianceRule(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}