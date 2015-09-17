namespace :ticket do
  desc "Generate 20 tickets for each brand."
  task generate: :environment do
    raise 'You should not be doing this in production environment !' if Rails.env.production?

    Brand.all.each do |brand|
      20.times do
        brand.tickets.create(code: rand.to_s[2..11])
      end
    end
  end
end