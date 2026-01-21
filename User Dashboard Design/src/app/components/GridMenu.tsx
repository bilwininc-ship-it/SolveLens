import { motion } from 'motion/react';
import { MessageSquare, Camera, FileText, TrendingUp, LucideIcon } from 'lucide-react';

interface MenuItem {
  id: string;
  title: string;
  description: string;
  icon: LucideIcon;
  color: string;
}

interface GridMenuProps {
  onNewInquiry?: () => void;
  onDocumentScan?: () => void;
  onResearchVault?: () => void;
  onAcademicInsights?: () => void;
}

const menuItems: MenuItem[] = [
  {
    id: 'inquiry',
    title: 'New Inquiry',
    description: 'Start a deep research conversation',
    icon: MessageSquare,
    color: '#00F0FF'
  },
  {
    id: 'scan',
    title: 'Document Scan',
    description: 'Camera & OCR analysis',
    icon: Camera,
    color: '#00F0FF'
  },
  {
    id: 'vault',
    title: 'Research Vault',
    description: 'History & saved notes',
    icon: FileText,
    color: '#00F0FF'
  },
  {
    id: 'insights',
    title: 'Academic Insights',
    description: 'AI-generated statistics',
    icon: TrendingUp,
    color: '#00F0FF'
  }
];

export function GridMenu({ onNewInquiry, onDocumentScan, onResearchVault, onAcademicInsights }: GridMenuProps) {
  const handleItemClick = (itemId: string) => {
    if (itemId === 'inquiry' && onNewInquiry) {
      onNewInquiry();
    } else if (itemId === 'scan' && onDocumentScan) {
      onDocumentScan();
    } else if (itemId === 'vault' && onResearchVault) {
      onResearchVault();
    } else if (itemId === 'insights' && onAcademicInsights) {
      onAcademicInsights();
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
      {menuItems.map((item, index) => (
        <motion.div
          key={item.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ 
            duration: 0.5, 
            delay: index * 0.1,
            ease: "easeOut" 
          }}
          whileHover={{ 
            y: -4,
            transition: { duration: 0.2 }
          }}
          className="group relative bg-white rounded-xl p-6 cursor-pointer overflow-hidden"
          style={{
            boxShadow: '0 2px 12px rgba(10, 25, 47, 0.06)',
            border: '1px solid rgba(10, 25, 47, 0.08)'
          }}
          onClick={() => handleItemClick(item.id)}
        >
          {/* Hover effect overlay */}
          <div 
            className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
            style={{
              background: 'linear-gradient(135deg, rgba(10, 25, 47, 0.02) 0%, rgba(0, 240, 255, 0.03) 100%)'
            }}
          />
          
          {/* Accent border on hover */}
          <div 
            className="absolute top-0 left-0 right-0 h-0.5 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"
            style={{ backgroundColor: item.color }}
          />
          
          <div className="relative z-10">
            <div className="flex items-start justify-between mb-4">
              <div 
                className="flex items-center justify-center w-12 h-12 rounded-lg transition-colors duration-300"
                style={{
                  backgroundColor: 'rgba(10, 25, 47, 0.05)',
                }}
              >
                <item.icon 
                  className="w-6 h-6 transition-colors duration-300"
                  style={{ 
                    color: '#0A192F',
                    strokeWidth: 1.5
                  }}
                />
              </div>
              
              <div 
                className="w-2 h-2 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                style={{ backgroundColor: item.color }}
              />
            </div>
            
            <h3 
              className="mb-2"
              style={{ 
                color: '#0A192F',
                fontFamily: 'var(--font-family-heading)',
                fontSize: '1.25rem'
              }}
            >
              {item.title}
            </h3>
            
            <p 
              className="text-sm opacity-60 leading-relaxed"
              style={{ 
                color: '#0A192F',
                fontFamily: 'var(--font-family-body)'
              }}
            >
              {item.description}
            </p>
          </div>
        </motion.div>
      ))}
    </div>
  );
}