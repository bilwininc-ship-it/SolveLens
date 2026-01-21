import { useState } from 'react';
import { motion } from 'motion/react';
import { MessageSquare, Camera, FileText, TrendingUp, Clock, ChevronRight } from 'lucide-react';
import { Header } from '@/app/components/Header';
import { ActiveTaskCard } from '@/app/components/ActiveTaskCard';
import { GridMenu } from '@/app/components/GridMenu';
import { RecentActivity } from '@/app/components/RecentActivity';
import { ChatInterface } from '@/app/components/ChatInterface';
import { DocumentScanScreen } from '@/app/components/DocumentScanScreen';
import { ResearchVaultScreen } from '@/app/components/ResearchVaultScreen';
import { AcademicInsightsScreen } from '@/app/components/AcademicInsightsScreen';

export default function App() {
  const [view, setView] = useState<'dashboard' | 'chat' | 'scan' | 'vault' | 'insights'>('dashboard');
  const credits = 3;
  const maxCredits = 15;

  if (view === 'chat') {
    return <ChatInterface onBack={() => setView('dashboard')} credits={credits} maxCredits={maxCredits} />;
  }

  if (view === 'scan') {
    return <DocumentScanScreen onBack={() => setView('dashboard')} />;
  }

  if (view === 'vault') {
    return <ResearchVaultScreen onBack={() => setView('dashboard')} />;
  }

  if (view === 'insights') {
    return <AcademicInsightsScreen onBack={() => setView('dashboard')} />;
  }

  return (
    <div className="min-h-screen" style={{ background: '#F9F9F7' }}>
      <div className="container mx-auto px-6 py-8 max-w-7xl">
        {/* Header */}
        <Header credits={credits} maxCredits={maxCredits} />
        
        {/* Main Hero Section - Active Task Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
          className="mt-12"
          onClick={() => setView('chat')}
        >
          <ActiveTaskCard />
        </motion.div>
        
        {/* Grid Menu - The 4 Pillars */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2, ease: "easeOut" }}
          className="mt-12"
        >
          <GridMenu 
            onNewInquiry={() => setView('chat')}
            onDocumentScan={() => setView('scan')}
            onResearchVault={() => setView('vault')}
            onAcademicInsights={() => setView('insights')}
          />
        </motion.div>
        
        {/* Recent Scholarly Activity */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4, ease: "easeOut" }}
          className="mt-16"
        >
          <RecentActivity />
        </motion.div>
      </div>
    </div>
  );
}