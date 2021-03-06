RSpec.describe MovieIndustry::Movie do
  let(:movie)            { described_class.new(movie_collection, params) }
  let(:movie_collection) { double }
  let(:existing_genres)  { %w[Crime Drama Action] }
  let(:params) do
    {
      imdb_link: 'http://imdb.com/title/tt0111161/?ref_=chttp_tt_1',
      title: 'The Shawshank Redemption',
      year: 1994,
      country: 'USA',
      release_at: '1994-10-14',
      genre: 'Crime,Drama',
      duration: '142 min',
      rate: '9.3',
      director: 'Frank Darabont',
      star_actors: 'Tim Robbins,Morgan Freeman,Bob Gunton'
    }
  end

  before do
    allow(movie_collection).to receive(:file_name).and_return('movies.txt')
    allow(movie_collection).to receive(:existing_genres).and_return(existing_genres)
  end

  describe '.create' do
    subject { described_class.create(movie_collection, params) }

    context 'when movie created in 1900-1945' do
      let(:params) { { year: 1945 } }

      it { is_expected.to be_an_instance_of(MovieIndustry::AncientMovie) }
    end

    context 'when movie created in 1945-1968' do
      let(:params) { { year: 1968 } }

      it { is_expected.to be_an_instance_of(MovieIndustry::ClassicMovie) }
    end

    context 'when movie created in 1968-2000' do
      let(:params) { { year: 2000 } }

      it { is_expected.to be_an_instance_of(MovieIndustry::ModernMovie) }
    end

    context 'when movie created after 2000' do
      let(:params) { { year: 2008 } }

      it { is_expected.to be_an_instance_of(MovieIndustry::NewMovie) }
    end

    context 'when movie year not set' do
      let(:params) { {} }

      it { is_expected.to be_an_instance_of(described_class) }
    end
  end

  describe '#to_s' do
    subject { movie.to_s }

    it { is_expected.to eq 'The Shawshank Redemption (1994-10-14; Crime/Drama) - 142 min' }
  end

  describe '#has_genre?' do
    subject(:has_genre) { movie.has_genre?(genre) }

    context 'when movie has testing genre' do
      let(:genre) { 'Drama' }

      it { is_expected.to be_truthy }
    end

    context 'when movie has no testing genre' do
      let(:genre) { 'Action' }

      it { is_expected.to be_falsey }
    end

    context 'when testing genre not present in movie_collection existing_genres' do
      let(:genre) { 'Opera' }

      it 'raise error with right message' do
        expect { has_genre }.to raise_error(RuntimeError, "There is no genre #{genre} in #{movie_collection.file_name}")
      end
    end

    context 'when testing genre is nil' do
      let(:genre) { nil }

      it 'raise error with right message' do
        expect { has_genre }.to raise_error(RuntimeError, "There is no genre #{genre} in #{movie_collection.file_name}")
      end
    end
  end

  describe '#matches?' do
    context 'when field is a String' do
      it 'matches the full string' do
        expect(movie.matches?(:title, 'The Shawshank Redemption')).to be(true)
      end

      it 'not matches the part string' do
        expect(movie.matches?(:title, 'The Shawshank')).to be(false)
      end

      it 'matches by regexp' do
        expect(movie.matches?(:title, /T.* Shawshank/)).to be(true)
      end
    end

    context 'when field is an Array' do
      it 'matches the full string in any Array element' do
        expect(movie.matches?(:genre, 'Drama')).to be(true)
      end

      it 'not matches the part string in any Array element' do
        expect(movie.matches?(:genre, 'Dra')).to be(false)
      end

      it 'matches by regexp' do
        expect(movie.matches?(:genre, /Dra/)).to be(true)
      end
    end

    context 'when field is a Date' do
      it 'matches the Data object' do
        expect(movie.matches?(:release_at, Date.new(1994, 10, 14))).to be(true)
      end

      it 'not matches the Data string' do
        expect(movie.matches?(:release_at, '1994-10-14')).to be(false)
      end

      it 'matches the DateTime object' do
        expect(movie.matches?(:release_at, DateTime.new(1994, 10, 14, 23, 1, 58))).to be(true)
      end

      it 'matches the Data range' do
        expect(movie.matches?(:release_at, (Date.new(1994, 10, 10)..Date.new(1994, 10, 20)))).to be(true)
      end
    end

    context 'when field is an Integer' do
      it 'matches the value' do
        expect(movie.matches?(:duration, 142)).to be(true)
      end

      it 'not matches the string' do
        expect(movie.matches?(:duration, '142')).to be(false)
      end

      it 'matches the value in float notation' do
        expect(movie.matches?(:duration, 142.0)).to be(true)
      end

      it 'matches the range' do
        expect(movie.matches?(:duration, (140..150))).to be(true)
      end
    end

    context 'when field is exclude_country' do
      it 'false if exclude_country eq movie country' do
        expect(movie.matches?(:exclude_country, 'USA')).to be(false)
      end

      it 'true if exclude_country NOT eq movie country' do
        expect(movie.matches?(:exclude_country, 'India')).to be(true)
      end
    end
  end

  describe '#month' do
    subject(:month) { movie.month }

    context 'when movie has release_at value' do
      it { is_expected.to eq 'October' }
    end
  end

  describe '#period' do
    subject { movie.period }

    it { is_expected.to eq :any }

    context 'when inherit from Movie' do
      let(:movie) { MovieIndustry::TestMovie.new(movie_collection) }

      before do
        test_movie = Class.new(described_class)
        stub_const('MovieIndustry::TestMovie', test_movie)
      end

      it { is_expected.to eq :test }
    end
  end
end
