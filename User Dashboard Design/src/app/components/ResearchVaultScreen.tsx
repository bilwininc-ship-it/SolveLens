import { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Search, Filter, Calendar, Tag, ChevronRight, FileText, MessageSquare, Image as ImageIcon } from 'lucide-react';

interface ResearchVaultScreenProps {
  onBack: () => void;
}

interface VaultItem {
  id: string;
  type: 'inquiry' | 'note' | 'document';
  title: string;
  preview: string;
  date: string;
  tags: string[];
  icon: typeof FileText;
}

const mockVaultItems: VaultItem[] = [
  {
    id: '1',
    type: 'inquiry',
    title: 'Dark matter and galaxy rotation curves',
    preview: 'The influence of dark matter on galactic rotation curves represents one of the most compelling pieces...',
    date: '2026-01-21',
    tags: ['Physics', 'Astrophysics', 'Dark Matter'],
    icon: MessageSquare
  },
  {
    id: '2',
    type: 'document',
    title: 'NFW Profile Analysis',
    preview: 'Navarro-Frenk-White density profile for dark matter halos. Mathematical formulation and observational evidence...',
    date: '2026-01-20',
    tags: ['Physics', 'Formula', 'Analysis'],
    icon: FileText
  },
  {
    id: '3',
    type: 'inquiry',
    title: 'Quantum entanglement principles',
    preview: 'Discussion on Bell\'s theorem and its implications for quantum mechanics and local realism...',
    date: '2026-01-19',
    tags: ['Physics', 'Quantum Mechanics'],
    icon: MessageSquare
  },
  {
    id: '4',
    type: 'note',
    title: 'Renaissance Art Movements',
    preview: 'Comparative analysis of Italian Renaissance and Northern Renaissance artistic techniques and philosophies...',
    date: '2026-01-18',
    tags: ['History', 'Art', 'Renaissance'],
    icon: FileText
  },
  {
    id: '5',
    type: 'inquiry',
    title: 'Computational complexity theory',
    preview: 'Exploration of P vs NP problem and its implications for computer science and cryptography...',
    date: '2026-01-17',
    tags: ['Computer Science', 'Mathematics', 'Theory'],
    icon: MessageSquare
  },
  {
    id: '6',
    type: 'document',
    title: 'Climate Change Data Analysis',
    preview: 'Statistical analysis of temperature trends and CO2 levels over the past century...',
    date: '2026-01-16',
    tags: ['Science', 'Statistics', 'Environment'],
    icon: ImageIcon
  }
];

export function ResearchVaultScreen({ onBack }: ResearchVaultScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<string | null>(null);
  const [sortBy, setSortBy] = useState<'date' | 'title'>('date');

  const allTags = Array.from(new Set(mockVaultItems.flatMap(item => item.tags)));

  const filteredItems = mockVaultItems.filter(item => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         item.preview.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         item.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase()));
    
    const matchesFilter = !selectedFilter || item.tags.includes(selectedFilter);
    
    return matchesSearch && matchesFilter;
  });

  return (
    <div 
      className="fixed inset-0 flex flex-col"
      style={{ background: '#F9F9F7' }}
    >
      {/* Header */}
      <div 
        className="flex items-center justify-between px-6 py-4"
        style={{ 
          background: '#F9F9F7',
          borderBottom: '1px solid rgba(10, 25, 47, 0.1)'
        }}
      >
        <button
          onClick={onBack}
          className="flex items-center gap-2 opacity-60 hover:opacity-100 transition-opacity"
          style={{ 
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </button>

        <h1
          className="text-2xl"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-heading)'
          }}
        >
          Research Vault
        </h1>

        <div className="w-20"></div>
      </div>

      {/* Search Bar */}
      <div className="px-6 py-4">
        <div
          className="flex items-center gap-3 px-4 py-3 rounded-xl"
          style={{
            background: '#ffffff',
            border: '1px solid rgba(10, 25, 47, 0.1)',
            boxShadow: '0 2px 8px rgba(10, 25, 47, 0.04)'
          }}
        >
          <Search className="w-5 h-5" style={{ color: '#0A192F', opacity: 0.4 }} />
          <input
            type="text"
            placeholder="Search inquiries, notes, and documents..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 bg-transparent outline-none"
            style={{
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)'
            }}
          />
        </div>
      </div>

      {/* Filter Tags */}
      <div className="px-6 pb-4">
        <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-thin">
          <button
            onClick={() => setSelectedFilter(null)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full whitespace-nowrap transition-all duration-200"
            style={{
              background: !selectedFilter ? '#0A192F' : 'rgba(10, 25, 47, 0.05)',
              color: !selectedFilter ? '#00F0FF' : '#0A192F',
              border: '1px solid rgba(10, 25, 47, 0.1)',
              fontFamily: 'var(--font-family-body)',
              fontSize: '0.875rem'
            }}
          >
            <Filter className="w-3.5 h-3.5" />
            All
          </button>
          
          {allTags.map(tag => (
            <button
              key={tag}
              onClick={() => setSelectedFilter(selectedFilter === tag ? null : tag)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full whitespace-nowrap transition-all duration-200"
              style={{
                background: selectedFilter === tag ? '#0A192F' : 'rgba(10, 25, 47, 0.05)',
                color: selectedFilter === tag ? '#00F0FF' : '#0A192F',
                border: '1px solid rgba(10, 25, 47, 0.1)',
                fontFamily: 'var(--font-family-body)',
                fontSize: '0.875rem'
              }}
            >
              <Tag className="w-3.5 h-3.5" />
              {tag}
            </button>
          ))}
        </div>
      </div>

      {/* Content List */}
      <div className="flex-1 overflow-y-auto px-6 pb-6 scrollbar-thin">
        <div className="space-y-3">
          {filteredItems.map((item, index) => (
            <motion.div
              key={item.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: index * 0.05 }}
              className="group flex items-start gap-4 p-5 rounded-xl cursor-pointer transition-all duration-200 hover:shadow-lg"
              style={{
                background: '#ffffff',
                border: '1px solid rgba(10, 25, 47, 0.08)',
                boxShadow: '0 2px 8px rgba(10, 25, 47, 0.04)'
              }}
            >
              {/* Icon */}
              <div
                className="flex items-center justify-center w-12 h-12 rounded-lg flex-shrink-0"
                style={{
                  background: 'rgba(10, 25, 47, 0.05)'
                }}
              >
                <item.icon className="w-6 h-6" style={{ color: '#0A192F', strokeWidth: 1.5 }} />
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0">
                <h3
                  className="mb-2"
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-heading)',
                    fontSize: '1.125rem'
                  }}
                >
                  {item.title}
                </h3>
                
                <p
                  className="mb-3 line-clamp-2"
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6,
                    lineHeight: '1.5'
                  }}
                >
                  {item.preview}
                </p>

                <div className="flex items-center gap-3 flex-wrap">
                  <div className="flex items-center gap-1.5 text-xs" style={{ color: '#0A192F', opacity: 0.4 }}>
                    <Calendar className="w-3.5 h-3.5" />
                    <span style={{ fontFamily: 'var(--font-family-body)' }}>
                      {new Date(item.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </span>
                  </div>

                  {item.tags.slice(0, 3).map(tag => (
                    <span
                      key={tag}
                      className="px-2 py-0.5 rounded text-xs"
                      style={{
                        background: 'rgba(10, 25, 47, 0.05)',
                        color: '#0A192F',
                        fontFamily: 'var(--font-family-body)',
                        fontWeight: 600,
                        fontSize: '0.75rem'
                      }}
                    >
                      #{tag}
                    </span>
                  ))}
                </div>
              </div>

              {/* Arrow */}
              <ChevronRight 
                className="w-5 h-5 opacity-0 group-hover:opacity-40 transition-opacity flex-shrink-0"
                style={{ color: '#0A192F' }}
              />
            </motion.div>
          ))}
        </div>

        {filteredItems.length === 0 && (
          <div className="text-center py-16">
            <p
              style={{
                color: '#0A192F',
                fontFamily: 'var(--font-family-body)',
                opacity: 0.4
              }}
            >
              No items found matching your search
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
